{ ... }:
let
  appName = "sm-devcontainer";
  imageName = "sm-devcontainer";
  workspaceDir = "/workspace";
  xdgDirShares = [
    "opencode"
    "sm-neovim"
  ];
in
{
  perSystem =
    {
      config,
      pkgs,
      ...
    }:
    let
      caBundle = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      image = pkgs.dockerTools.buildLayeredImage {
        name = imageName;
        tag = "latest";

        extraCommands = ''
          mkdir -p tmp
          mkdir -p etc/nix
          chmod 1777 tmp

          cat > etc/nix/nix.conf <<'EOF'
          experimental-features = nix-command flakes
          accept-flake-config = true
          warn-dirty = false
          EOF
        '';

        contents = [
          config.packages.sm-shell
        ];

        config = {
          Cmd = [
            "sm-shell"
          ];
          Env = [
            "HOME=/root"
            "LANG=C.UTF-8"
            "TERM=xterm-256color"
            "NIXPKGS_ALLOW_UNFREE=1"
            "SSL_CERT_FILE=${caBundle}"
            "NIX_SSL_CERT_FILE=${caBundle}"
            "GIT_SSL_CAINFO=${caBundle}"
            "CURL_CA_BUNDLE=${caBundle}"
            "XDG_CONFIG_HOME=/root/.config"
            "XDG_STATE_HOME=/root/.local/state"
            "XDG_DATA_HOME=/root/.local/share"
            "XDG_CACHE_HOME=/root/.cache"
          ];
          WorkingDir = workspaceDir;
        };
      };

      wrapper = pkgs.writeShellApplication {
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
          desired_image_id=$(${pkgs.gnutar}/bin/tar -xOf "$image_archive" manifest.json | ${pkgs.jq}/bin/jq -r '.[0].Config' | while IFS= read -r config_path; do printf '%s' "''${config_path%.json}"; done)
          current_image_id=$("$container_cli" image inspect "${imageName}:latest" --format '{{.Id}}' 2>/dev/null || true)
          current_image_id=''${current_image_id#sha256:}

          load_log=$(mktemp)
          trap 'rm -f "$load_log"' EXIT

          if [ "$current_image_id" = "$desired_image_id" ]; then
            echo "Image already loaded in $container_cli: ${imageName}:latest"
          else
            echo "Loading image to $container_cli..."
            if ! "$container_cli" load -i "$image_archive" > /dev/null 2> "$load_log"; then
              cat "$load_log" >&2
              exit 1
            fi
          fi

          host_xdg_config_home="''${XDG_CONFIG_HOME:-$HOME/.config}"
          host_xdg_data_home="''${XDG_DATA_HOME:-$HOME/.local/share}"
          host_xdg_state_home="''${XDG_STATE_HOME:-$HOME/.local/state}"
          host_xdg_cache_home="''${XDG_CACHE_HOME:-$HOME/.cache}"

          user_args=("$@")
          set -- "$container_cli" run --rm -it \
            -v "$PWD:${workspaceDir}"

          xdg_mounts=(
            "$host_xdg_config_home:/root/.config"
            "$host_xdg_data_home:/root/.local/share"
            "$host_xdg_state_home:/root/.local/state"
            "$host_xdg_cache_home:/root/.cache"
          )

          app_mounts=(${builtins.concatStringsSep " " (map (app: ''"${app}"'') xdgDirShares)})

          for app in "''${app_mounts[@]}"; do
            for xdg_mount in "''${xdg_mounts[@]}"; do
              host_base_dir="''${xdg_mount%%:*}"
              container_base_dir="''${xdg_mount#*:}"
              host_app_dir="$host_base_dir/$app"
              container_app_dir="$container_base_dir/$app"

              mkdir -p "$host_app_dir"
              set -- "$@" -v "$host_app_dir:$container_app_dir"
            done
          done

          exec "$@" \
            -w "${workspaceDir}" \
            "${imageName}:latest" \
            "''${user_args[@]}"
        '';
      };
    in
    {
      packages = {
        default = wrapper;
        ${appName} = wrapper;
        "${appName}-image" = image;
      };

      apps = {
        default = {
          type = "app";
          program = "${wrapper}/bin/${appName}";
        };

        ${appName} = {
          type = "app";
          program = "${wrapper}/bin/${appName}";
        };
      };
    };
}
