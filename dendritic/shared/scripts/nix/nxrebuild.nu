#!@nushell@/bin/nu

def main [action: string = "build"] {
  if not ($action in ["build", "switch"]) {
    print "usage: nxrebuild [build|switch]"
    exit 1
  }

  let hostname = (sys host | get hostname)
  let flake = $"($env.NIX_CONFIG_HOME)#($hostname)"

  if (sys host | get name) == "Darwin" {
    ^sudo darwin-rebuild $action --flake $flake
    return
  }

  # TODO: Work on removing --impure
  ^sudo nixos-rebuild $action --flake $flake --impure
}
