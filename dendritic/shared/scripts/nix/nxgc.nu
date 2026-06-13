#!@nushell@/bin/nu

def main [] {
  ^nix-collect-garbage --delete-old
  ^nix-store --optimise
}
