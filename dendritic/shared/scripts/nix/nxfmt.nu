#!@nushell@/bin/nu

def nix-files [] {
  ^find . -name "*.nix" -not -path "./nixpkgs/*" | lines | where { |file| ($file | str trim) != "" }
}

def main [] {
  nix-files | each { |file| ^@deadnix@/bin/deadnix -e -f $file }
  nix-files | each { |file| ^@nixfmt@/bin/nixfmt $file }
}
