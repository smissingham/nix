{ config, ... }:
let
  defaults = config.flake.defaults;
  shells = config.flake.shells;
in
{
  perSystem =
    { config, pkgs, ... }:
    let
      defaultShell =
        assert defaults.shell == "sm-zshell" || defaults.shell == "sm-nushell";
        defaults.shell;

      aliases = {
        # quick navigation
        q = "exit";
        cl = "clear";
        la = "ls -la";
        ll = "eza -la";
        lt = "eza -lT";

        # hero binds
        kk = "sesh_browser";
        kj = "sm-neovim";

        # custom wrapper exports
        ds = "sm-shell";
        nu = "sm-nushell";
        zsh = "sm-zshell";
        tv = "sm-television";
        tmux = "sm-tmux";

        # shortcuts
        dc = "docker run -it --rm -v ./:/workspace smissingham/devcontainer";
        oc = "opencode --port";

        # cli favourites
        gg = "lazygit";

        # television channels
        ff = "sm-television files";
        fD = "sm-television downloads";
        fp = "sm-television procs";
        fj = "sm-television journal";
        fn = "sm-television nixpkgs";
        fe = "sm-television env";
        ft = "sm-television text";
        fz = "sm-television zoxide";
        fcc = "sm-television podman-containers";
        fci = "sm-television podman-images";
      };

      devtools =
        with pkgs;
        [
          # Core utilities
          git
          gcc
          gnutar
          zip
          curl
          stow

          # Environment helpers
          direnv
          nix-direnv

          # System inspection
          fastfetch
          tealdeer
          btop
          htop
          dust

          # Parsing and display
          jq
          yq
          bat

          # Search and navigation
          zoxide
          fd
          ripgrep
          fzf
          eza
          yazi

          # Services
          gh
          glab
          jira-cli-go

          # Applications
          opencode
        ]
        ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
          # busybox causes logger issues on non-nixos linux installs
        ];

      cliToolPackages =
        devtools
        ++ config.scripts
        ++ [
          config.packages.sm-neovim
          config.packages.sm-television
        ];

      tmuxRuntimeTools = [
        config.packages.${defaultShell}
        config.packages.sm-neovim
        config.packages.sm-television
        pkgs.fd
        pkgs.fzf
      ];
    in
    {
      packages.sm-shell = pkgs.writeShellApplication {
        name = "sm-shell";
        runtimeEnv = shells.env;
        runtimeInputs = [ config.packages.${defaultShell} ];
        text = ''exec ${config.packages.${defaultShell}}/bin/${defaultShell} "$@"'';
      };

      packages.sm-cli-tools = pkgs.symlinkJoin {
        name = "sm-cli-tools";
        paths = cliToolPackages;
      };

      _module.args.shell-common = {
        inherit
          aliases
          cliToolPackages
          devtools
          tmuxRuntimeTools
          ;
      };
    };
}
