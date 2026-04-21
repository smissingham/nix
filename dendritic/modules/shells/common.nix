{ ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      tmux = "sm-tmux";
      tv = "sm-television";
    in
    {

      _module.args.shell-common = {

        aliases = {
          # quick navigation
          q = "exit";
          cl = "clear";

          # custom wrapper exports
          nu = "sm-nushell";
          zsh = "sm-zshell";
          ds = "sm-shell";
          dv = "sm-neovim";
          dc = "sm-devcontainer";
          oc = "sm-opencode";
          tv = tv;
          tmux = tmux;

          # cli favourites
          gg = "lazygit";

          # television channels
          ff = "${tv} files";
          fD = "${tv} downloads";
          fp = "${tv} procs";
          fj = "${tv} journal";
          fs = "sesh_browser";
          fn = "${tv} nixpkgs";
          fe = "${tv} env";
          ft = "${tv} text";
          fz = "${tv} zoxide";
          fcc = "${tv} podman-containers";
          fci = "${tv} podman-images";
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
