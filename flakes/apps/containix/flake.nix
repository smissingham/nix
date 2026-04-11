{
  description = "Nix flake for 'containix', a sandboxed nix container";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    smissingham-nvim = {
      url = "path:../smissingham-nvim";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        # Nix packages and toolchain
        overlays = [ ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        pkgsUnstable = import nixpkgs-unstable {
          inherit system;
        };

        # Packages for Linux container (cross-compiled if needed)
        linuxSystem = "${dockerArch}-linux";
        linuxPkgs = import nixpkgs {
          system = linuxSystem;
          inherit overlays;
        };
        containerSystem = nixpkgs.lib.nixosSystem {
          system = linuxSystem;
        };

        containerUserHomeDir = "/root";
        containerUserConfigDir = "${containerUserHomeDir}/.config";
        containerWorkingDir = "/data";

        # image info
        pName = "containix";
        pVersion = "0.1";
        containerId = "${pName}:${pVersion}";

        dockerArch = if pkgs.stdenv.isAarch64 then "aarch64" else "x86_64";
        detectContainerCli = ''
          if [[ -n "''${PODMAN_HOST-}" || -n "''${CONTAINER_HOST-}" ]]; then
            CONTAINER_CLI="podman"
          elif [[ -n "''${DOCKER_HOST-}" ]]; then
            CONTAINER_CLI="docker"
          elif command -v podman >/dev/null 2>&1; then
            CONTAINER_CLI="podman"
          elif command -v docker >/dev/null 2>&1; then
            CONTAINER_CLI="docker"
          else
            echo "Could not find podman or docker"
            exit 1
          fi
        '';
        pWrapper = pkgs.writeShellScriptBin pName ''
          set -euo pipefail
          ${detectContainerCli}

          echo "Building ${pName} image..."
          IMAGE_TAR=$(nix build .#docker --no-link --print-out-paths)

          echo "Loading ${pName} image to $CONTAINER_CLI..."
          $CONTAINER_CLI load -i "$IMAGE_TAR"
          $CONTAINER_CLI tag ${containerId} ${pName}:latest

          echo "Done. You can now call '$CONTAINER_CLI run ${containerId}' to use it"

          # try for git-repo name, fallback to parent dir
          REPO_NAME=$(basename $(git rev-parse --show-toplevel 2>/dev/null || pwd))

          # container name = containix:reponame
          CONTAINER_NAME="${pName}:$REPO_NAME"

          echo "Starting container with name $CONTAINER_NAME"

          # run the docker container, persist the root user home and bind pwd to /data
          $CONTAINER_CLI run --rm \
            -v containix-root:${containerUserHomeDir} \
            -v containix-nix:/nix \
            -p 4096:4096 \
            -v $(pwd):${containerWorkingDir} \
            -w ${containerWorkingDir} \
            -it ${containerId} 
        '';

        containerPackages = containerSystem.config.environment.systemPackages;
        #++ smissingham-nvim.packages.${linuxSystem}.systemPackages;

        systemPackages = [ pWrapper ];

        baseImageName = "nixos/nix";
        baseImageVersion = "2.33.4";
        imageManifests = {
          "x86_64" = {
            digest = "sha256:e79a39f468fc31dc811d236be65dbf724cd7f4abbbf1bab360460860892a5a9c";
            sha256 = "sha256-8KHv9vi6r/mx1CFHlzQ4PHsCChWyhT5T0eANFhEb4As=";
          };
          "aarch64" = {
            digest = "";
            sha256 = "";
          };
        };

      in
      {

        # Main docker image sandbox (the primary output of this flake)
        packages.docker = pkgsUnstable.dockerTools.buildLayeredImage {
          name = pName;
          tag = pVersion;
          maxLayers = 125;

          fromImage = pkgs.dockerTools.pullImage {
            os = "linux";
            arch = dockerArch;
            imageName = baseImageName;
            finalImageName = baseImageName;
            finalImageTag = baseImageVersion;
            imageDigest = imageManifests.${dockerArch}.digest;
            sha256 = imageManifests.${dockerArch}.sha256;
          };

          extraCommands = "";

          config = {
            Cmd = [
              "sh"
              "-c"
              "cd /data && fastfetch && exec sh"
            ];
            Env = [
              "TERM=xterm-256color"
              "LANG=C.UTF-8"
              "HOME=${containerUserHomeDir}"
              "XDG_CONFIG_HOME=${containerUserConfigDir}"
              "PATH=${linuxPkgs.lib.makeBinPath containerPackages}:/bin:/usr/bin"
            ];
          };

          contents =
            containerPackages
            #++ smissingham-nvim.packages.${system}.systemPackages
            ++ [
            ];
        };

        # Expose the runAlias as an installable binary for nix systems
        packages = {
          default = pWrapper;
          ${pName} = pWrapper;
          inherit systemPackages;
        };

        apps = {
          default = {
            type = "app";
            program = "${pWrapper}/bin/${pName}";
          };
        };

      }
    )
    // {
      sharedModules.default =
        {
          pkgs,
          ...
        }:
        {
          environment.systemPackages = self.packages.${pkgs.system}.systemPackages;
        };
    };
}
