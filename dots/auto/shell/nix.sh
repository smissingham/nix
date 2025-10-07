alias nxshell='nix-shell -p'

nxflake() {
  nix flake init --template "$NIX_CONFIG_HOME"/flakes/templates#"$*"
}

nxrepl() {
  nix repl --expr 'import <nixpkgs>{}'
}

# Build a package.nix file with callPackage
# Usage: nix-build-pkg ./package.nix
# Usage: nix-build-pkg ./package.nix '{ someArg = "value"; }'
nxbuild() {
  local package_file="${1:-./package.nix}"
  local args="${2:-{}}"

  export NIXPKGS_ALLOW_UNFREE=1

  if [[ ! -f "$package_file" ]]; then
    echo "Error: Package file '$package_file' not found"
    return 1
  fi

  nix-build --quiet --no-build-output -E "(import <nixpkgs> {}).callPackage $package_file $args"
}
