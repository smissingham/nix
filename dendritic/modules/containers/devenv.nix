{ ... }:
let
  appName = "sm-devenv";
  imageName = "sm-devenv";
  workspaceDir = "/workspace";
in
{
  perSystem =
    {
      config,
      pkgs,
      ...
    }:
    let
      image = pkgs.dockerTools.buildLayeredImage {
        name = imageName;
        tag = "latest";

        extraCommands = ''
          mkdir -p tmp
          chmod 1777 tmp
        '';

        contents = [
          config.packages.sm-neovim
          config.packages.sm-zsh
        ];

        config = {
          Cmd = [
            "${config.packages.sm-zsh}/bin/sm-zsh"
          ];
          Env = [
            "HOME=/root"
            "LANG=C.UTF-8"
            "TERM=xterm-256color"
            "XDG_CONFIG_HOME=/root/.config"
          ];
          WorkingDir = workspaceDir;
        };
      };

      runner = pkgs.writeShellApplication {
        name = appName;
        text = ''
          set -euo pipefail

          if command -v podman >/dev/null 2>&1; then
            container_cli="podman"
          elif command -v docker >/dev/null 2>&1; then
            container_cli="docker"
          else
            echo "Could not find podman or docker" >&2
            exit 1
          fi

          image_archive=${image}

          load_log=$(mktemp)
          trap 'rm -f "$load_log"' EXIT

          echo "Loading image to $container_cli..."
          if ! "$container_cli" load -i "$image_archive" > /dev/null 2> "$load_log"; then
            cat "$load_log" >&2
            exit 1
          fi

          exec "$container_cli" run --rm -it \
            -v "$PWD:${workspaceDir}" \
            -w "${workspaceDir}" \
            "${imageName}:latest" \
            "$@"
        '';
      };
    in
    {
      packages = {
        default = runner;
        ${appName} = runner;
        "${appName}-image" = image;
      };

      apps = {
        default = {
          type = "app";
          program = "${runner}/bin/${appName}";
        };

        ${appName} = {
          type = "app";
          program = "${runner}/bin/${appName}";
        };
      };
    };
}
