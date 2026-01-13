{
  description = "Nix flake for building containix sandbox dev container";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        # where to build the docker image on disk
        buildDir = "/tmp/containix";

        # image info
        pName = "containix";
        pVersion = "0.1";
        containerId = "${pName}:${pVersion}";

        # Nix packages and toolchain
        overlays = [ ];
        pkgs = import nixpkgs {
          #config.allowUnfree = true;
          inherit system overlays;
        };

        dockerAlias = "podman";

        mainWrapper = pkgs.writeShellScriptBin "${pName}-run" ''
          # only build and load if image doesn't already exist on host
          # TODO: make this detect hash diff
          if [[ -z $(${dockerAlias} images -q ${containerId}) ]]; then
            echo "Building ${pName} image..."
            mkdir -p ${buildDir}
            nix build .#docker -o ${buildDir}/${pName}-docker-image.tar.gz

            echo "Loading ${pName} image to ${dockerAlias}..."
            ${dockerAlias} load < ${buildDir}/${pName}-docker-image.tar.gz
            ${dockerAlias} tag ${containerId} ${pName}:latest

            echo "Cleaning up..."
            rm ${buildDir}/${pName}-docker-image.tar.gz

            echo "Done. You can now call '${dockerAlias} run ${containerId}' to use it"
          fi

          # TODO: Name the container after detected git repo
          ${dockerAlias} run -it ${containerId}
        '';

        systemPackages = with pkgs; [
          mainWrapper
          zsh
          yazi
          fzf
          eza
        ];

        baseImageName = "nixos/nixos";
        baseImageVersion = "25.05";

        # TODO: support arm image
        amd64Manifest = "sha256:d078d7153763895fce17c5fbbdeb86fcfcac414ca0ba875d413c1df57be19931";
        amd64SHA256 = "sha256-Tuvew+O8CDteF94NWX9pUugA++7UxViJmqR+yPt3H1g=";

      in
      {

        # Development shell, for testing & building this as a package
        devShells.default = pkgs.mkShell {
          buildInputs = systemPackages ++ [
            # devshell aliases
            (pkgs.writeShellScriptBin "inspect" ''
              ${dockerAlias} manifest inspect ${baseImageName}:${baseImageVersion} --verbose
            '')
          ];
          shellHook = ''
            Welcome to the ${pName} dev shell, for testing and building this flake.
          '';
        };

        # Main docker image sandbox (the primary output of this flake)
        packages.docker = pkgs.dockerTools.buildLayeredImage {
          name = pName;
          tag = pVersion;
          maxLayers = 125;

          fromImage = pkgs.dockerTools.pullImage {
            imageName = baseImageName;
            finalImageName = baseImageName;
            finalImageTag = baseImageVersion;
            imageDigest = amd64Manifest;
            sha256 = amd64SHA256;
            os = "linux";
            arch = "x86_64";

          };

          config = {
            Cmd = [ "/bin/sh" ];
            Env = [
              "PATH=${pkgs.lib.makeBinPath systemPackages}:/bin:/user/bin"
            ];
          };

          contents = systemPackages;
        };

        # Expose the runAlias as an installable binary for nix systems
        packages = {
          ${pName} = mainWrapper;
          default = mainWrapper;
          inherit systemPackages;
        };

      }
    );
}
