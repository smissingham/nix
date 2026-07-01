flake@{ inputs, lib, ... }:
let
  name = "vm-dev";

  dotfiles = ../../dotfiles;

  mutableDotfileApps = [
    "opencode"
  ];

  microVmsDataPath = "$HOME/.local/share/microvms";

  guestSystemFor = system: lib.replaceStrings [ "darwin" ] [ "linux" ] system;
  hypervisorFor = pkgs: if pkgs.stdenv.hostPlatform.isDarwin then "vfkit" else "qemu";

  mkVmModule =
    {
      guestSystem,
      hypervisor,
      vmHostPackages,
    }:
    { config, lib, ... }:
    {
      imports = [
        flake.config.profiles.smissingham
        flake.config.hosts.shared
      ];

      # ---------- NIX SYSTEM SETTINGS ----------#

      system.stateVersion = inputs.nixpkgs-stable.lib.trivial.release;
      nixpkgs.hostPlatform = guestSystem;
      nixpkgs.overlays = [ (_: _: inputs.self.packages.${guestSystem}) ];
      nix.optimise.automatic = false;

      environment = {
        systemPackages = [
          config.user.shell.package
          inputs.self.packages.${guestSystem}.sm-devtools
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
      };
      services.getty.autologinUser = config.user.username;
      security.sudo.wheelNeedsPassword = false;

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

      systemd.tmpfiles.rules = [
        "d ${config.user.paths.home} 0700 ${config.user.username} users -"
        "d ${config.user.paths.config} - ${config.user.username} users -"
        "d ${config.user.paths.home}/.local 0700 ${config.user.username} users -"
        "d ${config.user.paths.data} - ${config.user.username} users -"
        "d ${config.user.paths.state} - ${config.user.username} users -"
      ];

      system.activationScripts.dotfiles = lib.stringAfter [ "users" ] ''
        mkdir -p ${config.user.paths.config} ${config.user.paths.data} ${config.user.paths.state}

        # Copy config into the mutable guest home instead of symlinking into
        # /nix/store; some tools write state into their config dirs.
        for source in ${dotfiles}/.config/*; do
          target=${config.user.paths.config}/$(basename "$source")

          rm -rf "$target"
          cp -R "$source" "$target"
          chown -R ${config.user.username}:users "$target"
        done

        for app in ${lib.escapeShellArgs mutableDotfileApps}; do
          for pair in \
            "${dotfiles}/.local/share/$app:${config.user.paths.data}/$app" \
            "${dotfiles}/.local/state/$app:${config.user.paths.state}/$app"
          do
            source=''${pair%%:*}
            target=''${pair#*:}

            if [ ! -e "$source" ]; then
              continue
            fi

            rm -rf "$target"
            cp -R "$source" "$target"
            chown -R ${config.user.username}:users "$target"
          done
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
        ];
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
      guestShell = vmSystem.config.user.shell.path;
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
            rmdir "$shared_data_path/lock"
          }
          trap release_lock EXIT

          ln -sfn "$PWD" "$vm_data_path/workspace"
          # microvm volume paths are static, so use a relative image name in
          # the VM config and point it at the shared overlay from this cwd.
          ln -sfn "$shared_data_path/nix-store-overlay.img" "$vm_data_path/nix-store-overlay.img"
          rm -f "$vm_data_path/control/command" "$vm_data_path/control/stdout" "$vm_data_path/control/stderr" "$vm_data_path/control/exit"

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
