{ inputs, ... }:
let
  pname = "sm-zsh";
in
{
  perSystem =
    {
      config,
      pkgs,
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
        kk = "sesh_browser";
        kj = "sm-neovim";
        oc = "opencode --port";
        gg = "lazygit";

        # custom wrapper overrides
        tv = "sm-television";
        tmux = "sm-tmux";
        vm = "nix run $NIX_CONFIG_HOME#vm-dev";

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
        config.packages.sm-television
      ];

      wrapped = inputs.wrapper-modules.wrappers.zsh.wrap {
        inherit pkgs;

        prefixVar = [
          [
            "PATH"
            ":"
            (pkgs.lib.concatStringsSep ":" [
              "/run/wrappers/bin"
              "/run/current-system/sw/bin"
              "/nix/var/nix/profiles/default/bin"
              "/usr/local/bin"
              "/usr/bin"
              "/bin"
              "/usr/sbin"
              "/sbin"
            ])
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
          eval "$(${config.packages.sm-television}/bin/tv init zsh)"
          eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"
        '';

        zshAliases = aliases;
        runtimePkgs = runtimeInputs;
      };

    in
    {
      packages.${pname} = pkgs.writeShellApplication {
        name = pname;
        inherit runtimeInputs;
        text = ''exec ${wrapped}/bin/zsh "$@"'';
        passthru.shellPath = "/bin/${pname}";
        meta.description = "Sean's wrapped zsh shell";
      };

      devShells.default = pkgs.mkShell {
        packages = [ config.packages.sm-devtools ];
        SHELL = "${config.packages.${pname}}/bin/${pname}";
        shellHook = ''
          if [ -z "''${SM_DEV_SHELL:-}" ] && [ -t 0 ]; then
            export SM_DEV_SHELL=1
            exec ${config.packages.${pname}}/bin/${pname}
          fi
        '';
      };

    };
}
