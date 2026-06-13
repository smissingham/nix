#!@nushell@/bin/nu

def nix-files [] {
  ^find . -name "*.nix" -not -path "./nixpkgs/*" | lines | where { |file| ($file | str trim) != "" }
}

def main [] {
  for file in (nix-files) {
    ^@deadnix@/bin/deadnix -e -f $file
  }

  for file in (nix-files) {
    ^@nixfmt@/bin/nixfmt $file
  }
}
