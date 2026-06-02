{ ... }:
{
  perSystem =
    { config, pkgs, ... }:
    let
      neovim = "sm-neovim";
      nushell = "sm-nushell";
      shell = "sm-shell";
      tmux = "sm-tmux";
      tv = "sm-television";
      zshell = "sm-zshell";

      aliases = {
        # quick navigation
        q = "exit";
        cl = "clear";
        la = "ls -la";
        ll = "eza -la";
        lt = "eza -lT";

        # custom wrapper exports
        nu = nushell;
        zsh = zshell;
        ds = shell;
        dv = neovim;
        tv = tv;
        tmux = tmux;

        # shortcuts
        dc = "docker run -it --rm -v ./:/workspace smissingham/devcontainer";
        dcl = "nix run $env.NIX_CONFIG_HOME/dendritic#sm-devcontainer";
        oc = "opencode --port";

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

      env = {
        TERM = "xterm-256color";
      };
    in
    {
      packages.${shell} = pkgs.writeShellApplication {
        name = shell;
        runtimeEnv = env;
        runtimeInputs = [ config.packages.${nushell} ];
        text = ''exec ${config.packages.${nushell}}/bin/${nushell} "$@"'';
      };

      _module.args.shell-common = {
        inherit aliases env scripts;
      };
    };
}
