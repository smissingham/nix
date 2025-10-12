{
  pkgs,
  config,
  mainUser,
  ...
}:
let
  sysConfig = config;
  nixConfigHome = sysConfig.environment.variables.NIX_CONFIG_HOME;
  hostRebuildCli = (if pkgs.stdenv.isDarwin then "sudo darwin-rebuild" else "sudo nixos-rebuild");
in
{
  config = {
    home-manager.users.${mainUser.username}.home.packages = [ pkgs.nix-search-tv ];

    mySharedModules.home.shells = {
      aliases = {
        nxsh = "nix-shell -I nixpkgs=channel:nixos-unstable -p";
      };

      scripts = {
        # Format all Nix files in current directory (remove dead code and format)
        nxfmt = ''
          find . -name '*.nix' -exec ${pkgs.deadnix}/bin/deadnix -e -f {} \;
          find . -name '*.nix' -exec ${pkgs.nixfmt-rfc-style}/bin/nixfmt {} \;
        '';

        # Update all flake locks in Nix config directory
        nxu = ''
          set -e
          pushd ${nixConfigHome} > /dev/null || exit 1
            find . -name "flake.lock" -delete
            nix flake update
          popd > /dev/null
        '';

        # Rebuild system configuration (format, preserve git index, rebuild, restore git index)
        nxr = ''
          set -e
          pushd ${nixConfigHome} > /dev/null || exit 1
            nxfmt

            cp .git/index .git/index.backup
           
            git add . > /dev/null 2>&1

            ${hostRebuildCli} switch --flake .#$(hostname) --impure --show-trace
            
            mv .git/index.backup .git/index
          popd > /dev/null
        '';

        # Garbage collect old generations and optimize Nix store
        nxgc = ''
          nix-collect-garbage --delete-old
          nix-store --optimise
        '';

        # Interactive fuzzy search for Nix packages
        nxs = builtins.readFile (
          pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/3timeslazy/nix-search-tv/main/nixpkgs.sh";
            sha256 = "1z5jgi27yrisy3rwrba01kj2chpq68zdr5g5aalh5y5xd0rv0j3c";
          }
        );

        # Initialize new flake from templates in Nix config
        nxflake = ''
          nix flake init --template "${nixConfigHome}"/flakes/templates#"$*"
        '';

        # Start Nix REPL with nixpkgs loaded
        nxrepl = ''
          nix repl --expr 'import <nixpkgs>{}'
        '';

        # Build a package.nix file with optional args
        nxbuild = ''
          local package_file="''${1:-./package.nix}"
          local args="''${2:-{}}"

          export NIXPKGS_ALLOW_UNFREE=1

          if [[ ! -f "$package_file" ]]; then
            echo "Error: Package file '$package_file' not found"
            return 1
          fi

          nix-build --quiet --no-build-output -E "(import <nixpkgs> {}).callPackage $package_file $args"
        '';
      };
    };
  };
}
