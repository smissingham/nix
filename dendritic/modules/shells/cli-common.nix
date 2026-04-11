{ ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      scripts = [
        (pkgs.writeShellScriptBin "prompt-welcome" ''
          set -euo pipefail
          APP_NAME="''${1:-...}"
          clear
          gum style \
            --foreground "#38b2ac" \
            --border-foreground "#38b2ac" \
            --border double \
            --align center --width 50 --margin "1 1" --padding "1 1" \
            "Welcome to $APP_NAME"
          fastfetch
        '')
      ];
    in
    {
      _module.args.cliCommon = {
        packages =
          with pkgs;
          scripts
          ++ [

            # core utilities
            nix
            bash
            git
            ncurses
            coreutils
            findutils
            gnugrep
            gnused
            gnutar
            zip
            unzip
            xz
            _7zz
            gawk
            less
            curl
            wget
            stow

            # parsing
            jq
            bat

            # browsing
            zoxide
            fd
            ripgrep
            fzf
            eza
            yazi

            # sysinfo
            fastfetch
            tealdeer

            # appearance
            starship
            gum
          ];

        aliases = {
          # shell redirects
          zsh = "sm-zsh";

          # custom aliases
          q = "exit";
          cl = "clear";
          ls = "eza";
          ll = "eza -la";
        };
      };
    };
}
