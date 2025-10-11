{
  pkgs,
  config,
  ...
}:
let
  sysConfig = config;
  nixConfigHome = sysConfig.environment.variables.NIX_CONFIG_HOME;
  hostRebuildCli = (if pkgs.stdenv.isDarwin then "sudo darwin-rebuild" else "sudo nixos-rebuild");
in
{
  config = {
    mySharedModules.home.shells = {
      aliases = {
        nxsh = "nix-shell -I nixpkgs=channel:nixos-unstable -p";
      };

      scripts = {
        nxfmt = ''
          find . -name '*.nix' -exec ${pkgs.deadnix}/bin/deadnix -e -f {} \;
          find . -name '*.nix' -exec ${pkgs.nixfmt-rfc-style}/bin/nixfmt {} \;
        '';

        nxu = ''
          set -e
          pushd ${nixConfigHome} > /dev/null || exit 1
            find . -name "flake.lock" -delete
            nix flake update
          popd > /dev/null
        '';

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

        nxgc = ''
          nix-collect-garbage --delete-old
          nix-store --optimise
        '';

        nxs = ''
          ${pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/3timeslazy/nix-search-tv/main/nixpkgs.sh";
            sha256 = "1z5jgi27yrisy3rwrba01kj2chpq68zdr5g5aalh5y5xd0rv0j3c";
          }}
        '';

        nxflake = ''
          nix flake init --template "${nixConfigHome}"/flakes/templates#"$*"
        '';

        nxrepl = ''
          nix repl --expr 'import <nixpkgs>{}'
        '';

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
