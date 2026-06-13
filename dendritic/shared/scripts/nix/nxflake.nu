#!@nushell@/bin/nu

def main [template: string] {
  ^nix flake init --template $"($env.NIX_CONFIG_HOME)/flakes/templates#($template)"
}
