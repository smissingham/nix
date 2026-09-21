flake@{ inputs, lib, ... }:
let
  name = "vm-dev";

  # path to dotfiles to mount (as mutable) inside microvm guest
  dotfiles = ../../dotfiles;

  # where data volumes for microvms will be stored
  microVmsDataPath = "$HOME/.local/share/microvms";

  # Directories relative to $HOME, mounted read-write at the same guest paths.
  # Guest writes affect the host directly; do not list individual files.
  hostPaths = [
    ".local/share/opencode"
    ".local/state/opencode"
  ];

  guestSystemFor = system: lib.replaceStrings [ "darwin" ] [ "linux" ] system;
  hypervisorFor =
    pkgs: if pkgs.stdenv.hostPlatform.isDarwin then "vfkit" else "qemu";

  mkVmModule =
    {
      guestSystem,
      hypervisor,
      vmHostPackages,
    }:
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        flake.config.profiles.smissingham
        flake.config.hosts.shared
      ];

      # ---------- NIX SYSTEM SETTINGS ----------#

      system.stateVersion = inputs.nixpkgs.lib.trivial.release;
      nixpkgs.hostPlatform = guestSystem;
      nixpkgs.overlays = [ (_: _: inputs.self.packages.${guestSystem}) ];
      nix.optimise.automatic = false;

      environment = {
        enableAllTerminfo = true;
        systemPackages = [
          config.user.shell.package
          inputs.self.packages.${guestSystem}.sm-cli-devtools
        ];
      };

      networking = {
        hostName = name;
        nameservers = [
          "1.1.1.1"
          "1.0.0.1"
          "2606:4700:4700::1111"
          "2606:4700:4700::1001"
        ];
        firewall = {
          enable = true;
          extraCommands = ''
            iptables -A OUTPUT -d 10.0.0.0/8 -j REJECT
            iptables -A OUTPUT -d 172.16.0.0/12 -j REJECT
            iptables -A OUTPUT -d 192.168.0.0/16 -j REJECT
            iptables -A OUTPUT -d 169.254.0.0/16 -j REJECT
            ip6tables -A OUTPUT -d fc00::/7 -j REJECT
            ip6tables -A OUTPUT -d fe80::/10 -j REJECT
          '';
        };
      };

      # ---------- USER SETTINGS ----------#
      users.users.${config.user.username} = {
        isNormalUser = true;
        group = "users";
        hashedPassword = "!";
        extraGroups = [ "wheel" ];
        shell = lib.mkForce (
          "${pkgs.writeShellScriptBin "vm-dev-shell" ''
            cd ${lib.escapeShellArg "${config.user.paths.home}/workspace"} || exit 1
            exec ${config.user.shell.path} "$@"
          ''}/bin/vm-dev-shell"
        );
      };
      services.getty = {
        autologinUser = config.user.username;
        loginProgram = pkgs.writeShellScript "vm-dev-login" ''
          if [ -f /run/microvm-control/term ]; then
            IFS= read -r TERM < /run/microvm-control/term
            IFS= read -r COLORTERM < /run/microvm-control/colorterm
            export TERM COLORTERM
          fi
          exec ${pkgs.shadow}/bin/login -p "$@"
        '';
      };
      security.sudo.wheelNeedsPassword = false;

      # Serial consoles carry terminal bytes, but not window-size ioctls.
      systemd.services.vm-dev-terminal = {
        wantedBy = [ "multi-user.target" ];
        after = [ "run-microvm\\x2dcontrol.mount" ];
        requires = [ "run-microvm\\x2dcontrol.mount" ];
        unitConfig.ConditionPathExists = "/run/microvm-control/size";
        path = [ pkgs.coreutils ];
        script = ''
          console=/dev/${
            if hypervisor == "vfkit" then
              "hvc0"
            else if lib.hasPrefix "x86_64" guestSystem then
              "ttyS0"
            else
              "ttyAMA0"
          }
          while sleep 0.25; do
            read -r rows cols < /run/microvm-control/size || continue
            [[ "$rows" =~ ^[1-9][0-9]{0,4}$ && "$cols" =~ ^[1-9][0-9]{0,4}$ ]] || continue
            (( rows <= 65535 && cols <= 65535 )) || continue
            if [ "$(stty -F "$console" size)" != "$rows $cols" ]; then
              stty -F "$console" rows "$rows" cols "$cols"
            fi
          done
        '';
      };

      # If the host drops an executable command into the control share, run it
      # once as the VM user, write stdout/stderr/exit back, then shut down.
      systemd.services.vm-dev-command = {
        wantedBy = [ "multi-user.target" ];
        after = [ "run-microvm\\x2dcontrol.mount" ];
        requires = [ "run-microvm\\x2dcontrol.mount" ];
        path = [ config.systemd.package ];
        script = ''
          if [ ! -x /run/microvm-control/command ]; then
            exit 0
          fi

          set +e
          /run/wrappers/bin/sudo -Hu ${config.user.username} /run/microvm-control/command \
            > /run/microvm-control/stdout \
            2> /run/microvm-control/stderr
          status=$?
          printf '%s\n' "$status" > /run/microvm-control/exit
          poweroff
        '';
      };

      systemd.tmpfiles.rules =
        [
          config.user.paths.home
          config.user.paths.config
          "${config.user.paths.home}/.local"
          config.user.paths.data
          config.user.paths.state
        ]
        |> builtins.filter (
          path:
          !(builtins.any (
            shared:
            path == "${config.user.paths.home}/${shared}"
            || lib.hasPrefix "${config.user.paths.home}/${shared}/" path
          ) hostPaths)
        )
        |> map (path: "d ${path} 0700 ${config.user.username} users -");

      system.activationScripts.dotfiles = lib.stringAfter [ "users" ] ''
        mkdir -p ${config.user.paths.config} ${config.user.paths.data} ${config.user.paths.state}

        # Copy config into the mutable guest home instead of symlinking into
        # /nix/store; some tools write state into their config dirs.
        for source in ${dotfiles}/.config/*; do
          target=${config.user.paths.config}/$(basename "$source")

          # Never reset an app config that contains or lives in a host share.
          for shared in ${lib.escapeShellArgs hostPaths}; do
            shared=${config.user.paths.home}/$shared
            if [[ "$target/" == "$shared/"* || "$shared/" == "$target/"* ]]; then
              continue 2
            fi
          done

          rm -rf "$target"
          cp -R "$source" "$target"
          chown -R ${config.user.username}:users "$target"
        done
      '';

      # ---------- VM SETTINGS ----------#
      microvm = {
        inherit hypervisor vmHostPackages;
        vcpu = 4;
        mem = 8192;
        # Keep the VM isolated from the host store, but persist guest-side Nix
        # builds in one shared mutable overlay for all vm-dev workspaces.
        writableStoreOverlay = "/nix/.rw-store";
        shares = [
          {
            proto = "virtiofs";
            tag = "workspace";
            source = "workspace";
            mountPoint = "${config.user.paths.home}/workspace";
          }
          {
            proto = "virtiofs";
            tag = "control";
            source = "control";
            mountPoint = "/run/microvm-control";
          }
        ]
        ++ lib.imap0 (index: path: {
          proto = "virtiofs";
          tag = "home-${toString index}";
          source = "home-${toString index}";
          mountPoint = "${config.user.paths.home}/${path}";
        }) hostPaths;
        volumes = [
          {
            # Resolved relative to the per-workspace launch dir via the symlink
            # created by the wrapper below.
            image = "nix-store-overlay.img";
            mountPoint = config.microvm.writableStoreOverlay;
            size = 8192;
          }
        ];
        interfaces = [
          {
            type = "user";
            id = "usernet";
            mac = "02:00:00:00:00:01";
          }
        ];
      };
    };
in
{
  perSystem =
    { pkgs, system, ... }:
    let
      guestSystem = guestSystemFor system;
      vmSystem = inputs.nixpkgs.lib.nixosSystem {
        system = guestSystem;
        specialArgs.nixExperimentalFeatures = [
          "nix-command"
          "flakes"
          "pipe-operators"
        ];
        modules = [
          inputs.microvm-nix.nixosModules.microvm
          (mkVmModule {
            inherit guestSystem;
            hypervisor = hypervisorFor pkgs;
            vmHostPackages = pkgs;
          })
        ];
      };
      runner = vmSystem.config.microvm.declaredRunner;
      guestShell = vmSystem.config.users.users.${vmSystem.config.user.username}.shell;
    in
    {
      packages.${name} = pkgs.writeShellApplication {
        inherit name;
        text = ''
          # Each host workspace gets its own VM runtime dir so /workspace and
          # control files do not collide between projects.
          workspace_hash=$(printf '%s' "$PWD" | shasum -a 256)
          workspace_hash=''${workspace_hash%% *}
          vm_data_path="${microVmsDataPath}/${name}-''${workspace_hash:0:16}"
          shared_data_path="${microVmsDataPath}/${name}"

          mkdir -p "$vm_data_path/control" "$shared_data_path"
          # One shared writable Nix store overlay cannot be mounted by multiple
          # VMs safely, so serialize all vm-dev runs.
          if ! mkdir "$shared_data_path/lock"; then
            printf '%s\n' "${name} is already running" >&2
            exit 1
          fi
          release_lock() {
            if [ -n "''${terminal_monitor:-}" ]; then
              kill "$terminal_monitor" 2>/dev/null || true
              wait "$terminal_monitor" 2>/dev/null || true
            fi
            rmdir "$shared_data_path/lock"
          }
          trap release_lock EXIT

          ln -sfn "$PWD" "$vm_data_path/workspace"
          ${lib.concatImapStringsSep "\n" (index: path: ''
            mkdir -p "$HOME"/${lib.escapeShellArg path}
            ln -sfn "$HOME"/${lib.escapeShellArg path} "$vm_data_path/home-${toString (index - 1)}"
          '') hostPaths}
          # microvm volume paths are static, so use a relative image name in
          # the VM config and point it at the shared overlay from this cwd.
          ln -sfn "$shared_data_path/nix-store-overlay.img" "$vm_data_path/nix-store-overlay.img"
          rm -f "$vm_data_path/control/command" "$vm_data_path/control/stdout" "$vm_data_path/control/stderr" "$vm_data_path/control/exit"
          rm -f "$vm_data_path/control/term" "$vm_data_path/control/colorterm" "$vm_data_path/control/size"

          if [ "$#" -gt 0 ]; then
            command_mode=1
            {
              # Run exec-mode commands through the guest user's configured
              # shell so aliases/functions/environment match interactive use.
              printf '#!/run/current-system/sw/bin/sh\nexport PATH=/run/current-system/sw/bin\nexec %q -lc ' "${guestShell}"
              printf %q "exec$(printf ' %q' "$@")"
              printf '\n'
            } > "$vm_data_path/control/command"
            chmod +x "$vm_data_path/control/command"
          fi

          run_microvm() {
            ${
              if pkgs.stdenv.hostPlatform.isDarwin then
                "/usr/bin/script -q /dev/null ${runner}/bin/microvm-run"
              else
                "${runner}/bin/microvm-run"
            }
          }

          if [ -t 0 ]; then
            printf '%s\n' "''${TERM:-xterm-256color}" > "$vm_data_path/control/term"
            printf '%s\n' "''${COLORTERM:-}" > "$vm_data_path/control/colorterm"
            exec {terminal_fd}<&0
            sync_terminal_size() {
              size=$(stty size <&"$terminal_fd") || return
              if [ "$size" != "''${previous_size:-}" ]; then
                printf '%s\n' "$size" > "$vm_data_path/control/size.new"
                mv "$vm_data_path/control/size.new" "$vm_data_path/control/size"
                previous_size=$size
              fi
            }
            sync_terminal_size
            # Poll the original tty: shell WINCH traps wait for the VM to exit,
            # and filesystem notifications do not reliably cross virtiofs.
            (while sleep 0.25; do sync_terminal_size; done) &
            terminal_monitor=$!
            old_stty=$(stty -g)
            restore_tty() {
              stty "$old_stty"
            }
            cleanup() {
              restore_tty
              release_lock
            }
            trap cleanup EXIT
            stty intr undef
          fi

          cd "$vm_data_path"
          run_microvm

          if [ "''${command_mode:-0}" = 1 ]; then
            if [ ! -f "$vm_data_path/control/exit" ]; then
              cat "$vm_data_path/control/stderr" >&2 2>/dev/null || true
              exit 125
            fi
            cat "$vm_data_path/control/stdout"
            cat "$vm_data_path/control/stderr" >&2
            exit "$(cat "$vm_data_path/control/exit")"
          fi
        '';
        meta.description = "Run Sean's development MicroVM";
      };
    };
}
