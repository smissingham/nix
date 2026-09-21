{ inputs, ... }:
let
  pname = "sm-zsh";
in
{
  perSystem =
    {
      config,
      pkgs,
      sm-clibundles,
      ...
    }:
    let
      aliases = {
        # quick navigation
        q = "exit";
        qq = "sudo shutdown -h now";
        qr = "sudo reboot";
        cl = "clear";
        la = "ls -la";
        ll = "eza -la";
        lt = "eza -lT";

        # hero binds
        y = "sm-yazi";
        kk = "sesh_browser";
        kj = "sm-neovim";
        oc = "opencode --port";
        ocs = "opencode serve --hostname 0.0.0.0";
        gg = "lazygit";

        # custom wrapper overrides
        herdr = "sm-herdr";
        tv = "sm-television";
        tmux = "sm-tmux";
        vm = "nix run $NIX_CONFIG_HOME#vm-dev";
        vmoci = "nix run $NIX_CONFIG_HOME#vm-dev-oci";

        # television channels
        ff = "sm-television files";
        fD = "sm-television dirs";
        fp = "sm-television procs";
        fj = "sm-television journal";
        fn = "sm-television nixpkgs";
        fe = "sm-television env";
        ft = "sm-television text";
        fz = "sm-television zoxide";
        fcc = "sm-television podman-containers";
        fci = "sm-television podman-images";
      };

      runtimeInputs = [
        pkgs.atuin
        pkgs.starship
        pkgs.zoxide
        pkgs.zsh-autosuggestions
        pkgs.zsh-completions
        pkgs.zsh-syntax-highlighting
      ];

      wrapped = inputs.wrapper-modules.wrappers.zsh.wrap {
        inherit pkgs;

        prefixVar = [
          [
            "PATH"
            ":"
            (
              [
                "/run/wrappers/bin"
                "/run/current-system/sw/bin"
                "/nix/var/nix/profiles/default/bin"
                "/usr/local/bin"
                "/usr/bin"
                "/bin"
                "/usr/sbin"
                "/sbin"
              ]
              |> pkgs.lib.concatStringsSep ":"
            )
          ]
        ];
        skipGlobalRC = true;
        zdotdir = "$HOME/.config/${pname}";
        zshrc.content = ''
          bindkey -r '^L'
          bindkey -r '^J'

          fpath=(${pkgs.zsh-completions}/share/zsh/site-functions $fpath)
          autoload -Uz compinit && compinit

          source ${pkgs.zsh-autosuggestions}/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
          source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

          eval "$(${pkgs.atuin}/bin/atuin init zsh)"
          eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
          eval "$(${pkgs.starship}/bin/starship init zsh)"
          eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"
        '';

        zshAliases = aliases;
        runtimePkgs = runtimeInputs;
      };

      # hook script to trigger start/open of devshell
      shellHook = ''
        if [ -z "''${SM_DEV_SHELL:-}" ] && [ -t 0 ]; then
          export SM_DEV_SHELL=1
          exec ${config.packages.${pname}}/bin/${pname}
        fi
      '';
    in
    {
      packages.${pname} = pkgs.writeShellApplication {
        name = pname;
        inherit runtimeInputs;
        text = ''exec ${wrapped}/bin/zsh "$@"'';
        passthru.shellPath = "/bin/${pname}";
        meta.description = "Sean's wrapped zsh shell";
      };

      # Minimal devshell
      devShells.default = pkgs.mkShell {
        inherit shellHook;
        packages = [
          sm-clibundles.core
        ];
        SHELL = "${config.packages.${pname}}/bin/${pname}";
      };

      # Maximal devshell
      devShells.full = pkgs.mkShell {
        inherit shellHook;
        packages = [ sm-clibundles.devtools ];
        SHELL = "${config.packages.${pname}}/bin/${pname}";
      };

    };
}
