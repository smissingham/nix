#!@nushell@/bin/nu

def main [...args: string] {
  ^nix develop ...$args
}
