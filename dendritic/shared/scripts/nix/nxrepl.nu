#!@nushell@/bin/nu

def main [] {
  ^nix repl --expr "import <nixpkgs>{}"
}
