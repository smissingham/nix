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
      smissingham-nvim,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        # Nix packages and toolchain
        overlays = [ ];
        pkgs = import nixpkgs {
          #inherit system overlays;
          inherit overlays;
        };
        pkgsUnstable = import nixpkgs-unstable {
          #inherit system;
        };

        # Packages for Linux container (cross-compiled if needed)
        linuxPkgs = import nixpkgs {
          #system = linuxSystem;
          inherit overlays;
        };

        # where to build the container image on disk
        buildDir = "/tmp/containix";
        containerUserHomeDir = "/root";
        containerUserConfigDir = "${containerUserHomeDir}/.config";
        containerWorkingDir = "/data";

        # image info
        pName = "containix";
        pVersion = "0.1";
        containerId = "${pName}:${pVersion}";

        # TODO: connect to socket instead of assuming cli
        dockerAlias = "podman";
        dockerArch = if pkgs.stdenv.isAarch64 then "aarch64" else "x86_64";

        pWrapper = pkgs.writeShellScriptBin pName ''
          # only build and load if image doesn't already exist on host
          # TODO: make this detect hash diff
          if [[ -z $(${dockerAlias} images -q ${containerId}) ]]; then
            echo "Building ${pName} image..."
            mkdir -p ${buildDir}

          # TODO: fix dependency on local file build path
            nix build .#docker -o ${buildDir}/${pName}-docker-image.tar.gz

            echo "Loading ${pName} image to ${dockerAlias}..."
            ${dockerAlias} load < ${buildDir}/${pName}-docker-image.tar.gz
            ${dockerAlias} tag ${containerId} ${pName}:latest

            echo "Cleaning up..."
            rm ${buildDir}/${pName}-docker-image.tar.gz

            echo "Done. You can now call '${dockerAlias} run ${containerId}' to use it"
          fi

          # try for git-repo name, fallback to parent dir
          REPO_NAME=$(basename $(git rev-parse --show-toplevel 2>/dev/null || pwd))

          # container name = containix:reponame
          CONTAINER_NAME="${pName}:$REPO_NAME"

          echo "Starting container with name $CONTAINER_NAME"

          # run the docker container, persist the root user home and bind pwd to /data
          ${dockerAlias} run --rm \
            -v containix-root:${containerUserHomeDir} \
            -v containix-nix:/nix \
            -p 4096:4096 \
            -v $(pwd):${containerWorkingDir} \
            -w ${containerWorkingDir} \
            -it ${containerId} 
        '';

        containerPackages = with linuxPkgs; [
          nix
          git

          # critical cli utils
          coreutils
          findutils
          gnugrep
          gnused
          gawk
          less
          curl

          # nice-to-have's
          #zsh
          yazi
          fzf
          eza
          fastfetch
        ];
        #++ smissingham-nvim.packages.${linuxSystem}.systemPackages;

        systemPackages = [ pWrapper ];

        baseImageName = "nixos/nix";
        baseImageVersion = nixpkgs.lib.trivial.release;
        imageManifests = {
          "x86_64" = {
            digest = "sha256:d078d7153763895fce17c5fbbdeb86fcfcac414ca0ba875d413c1df57be19931";
            sha256 = "sha256-D+Ktuvq6nzkB0zHEPYr+jlMUA4dcoUqfcC4pnKJfzAI=";
          };
          "aarch64" = {
            digest = "sha256:9ad22c733bc2c3125acf443915fc1477ae446244a7889a60a04f89fde21f57d9";
            sha256 = "sha256-Y1UVRhqcmUWDESyczsPI6IQBU11wQfISNDGzmZQKDrg=";
          };
        };

      in
      {

        # Development shell, for testing & building this as a package
        devShells.default = pkgs.mkShell {
          buildInputs = containerPackages ++ [
            # devshell aliases
            (pkgs.writeShellScriptBin "inspect" ''
              ${dockerAlias} manifest inspect ${baseImageName} --verbose
            '')
          ];
          shellHook = ''
            Welcome to the ${pName} dev shell, for testing and building this flake.
          '';
        };

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
              "cd /data && fastfetch"
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
            ++ smissingham-nvim.packages.${system}.systemPackages
            ++ [
              # TODO: A nicer attrset to house these and parse to bins
              (pkgs.writeShellScriptBin "q" "exit")
              (pkgs.writeShellScriptBin "cl" "clear")
              (pkgs.writeShellScriptBin "oc" "opencode")
              (pkgs.writeShellScriptBin "sv" "smissingham-nvim")
              # TODO: put a nix config file in so the features are enabled by default
              (pkgs.writeShellScriptBin "nd" ''nix develop --extra-experimental-features "nix-command flakes"'')
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
