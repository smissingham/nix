#!@nushell@/bin/nu

def main [system?: string] {
  let target_system = if ($system | is-empty) {
    ^nix eval --raw --impure --expr builtins.currentSystem | str trim
  } else {
    $system
  }

  ^nix-build -E $'with import <nixpkgs> { system = "($target_system)"; }; callPackage ./package.nix {}'
}
