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

        # Shorthand for nix devshell activation
        nd = ''nix develop'';

        # Build a local package.nix file for nixpkgs
        nxpkg = ''
          local sys="''${1:-$(nix eval --raw --impure --expr builtins.currentSystem)}"
          nix-build -E "(import <nixpkgs> { system = \"$sys\"; }).callPackage ./package.nix {}"
        '';

        # Format all Nix files in current directory (remove dead code and format)
        nxfmt = ''
          find . -name '*.nix' -not -path './nixpkgs/*' -exec ${pkgs.deadnix}/bin/deadnix -e -f {} \;
          find . -name '*.nix' -not -path './nixpkgs/*' -exec ${pkgs.nixfmt-rfc-style}/bin/nixfmt {} \;
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

        # Rebuild with logging to local text file
        nxrl = ''
          nxr 2>&1 | tee ${nixConfigHome}/build.log
          return ''${PIPESTATUS[0]}
        '';

        # Garbage collect old generations and optimize Nix store
        nxgc = ''
          nix-collect-garbage --delete-old
          nix-store --optimise
        '';

        # Interactive fuzzy search for Nix packages
        nxs = builtins.readFile (
          pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/3timeslazy/nix-search-tv/c7919f34fde2e87de3fe70c74bf18c7e0091f19b/nixpkgs.sh";
            sha256 = "sha256-XkBL7EdPIETdi8B5k0ww3d66xB7QnW+mFEK2RUihWcY=";
          }
        );

        # Initialize new flake from templates in Nix config
        nxflake = ''
          nix flake init --template "${nixConfigHome}"/flakes/templates#"''$1"
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

        # Check flake for both Darwin and NixOS configurations
        nxc = ''
          set -e
          check_hosts() {
            nix eval ".#$1" --apply builtins.attrNames --json --impure | ${pkgs.jq}/bin/jq -r '.[]' | while read host; do
              nix build ".#$1.$host.$2" --dry-run --show-trace --impure
            done
          }
          pushd ${nixConfigHome} > /dev/null || exit 1
            check_hosts darwinConfigurations system
            check_hosts nixosConfigurations config.system.build.toplevel
          popd > /dev/null
        '';
      };
    };
  };
}
