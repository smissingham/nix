#!@nushell@/bin/nu

def main [action: string = "build"] {
  if not ($action in ["build", "switch"]) {
    print "usage: nxrebuild [build|switch]"
    exit 1
  }

  cd $env.NIX_CONFIG_HOME
  ^nxfmt

  let hostname = (sys host | get hostname)
  let flake = $".#($hostname)"

  if $action == "switch" {
    ^cp .git/index .git/index.backup
    ^git add .
  }

  if (sys host | get name) == "Darwin" {
    ^sudo darwin-rebuild $action --flake $flake --impure --show-trace
  } else {
    ^sudo nixos-rebuild $action --flake $flake --impure --show-trace
  }

  if $action == "switch" {
    ^mv .git/index.backup .git/index
    return
  }
}
