{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {

      _module.args.shell-common = {

        aliases = {
          # main package exports
          ds = "sm-devshell";
          dv = "sm-neovim";
          dc = "sm-devcontainer";
          oc = "sm-opencode";

          # redirect shells to custom wrapped shells
          zsh = "sm-zsh";
          nu = "sm-nu";

          # quick navigation
          q = "exit";
          cl = "clear";
          ls = "eza";
          ll = "eza -la";
          ff = "tv";
        };

        scripts = [
          (pkgs.writeShellScriptBin "whereami" ''
            set -euo pipefail
            APP_NAME="''${1:-...}"
            clear
            gum style \
              --foreground "#38b2ac" \
              --border-foreground "#38b2ac" \
              --border double \
              --align center --width 50 --margin "1 1" \
              "Welcome to $APP_NAME"
            fastfetch
          '')
        ];
      };
    };
}
