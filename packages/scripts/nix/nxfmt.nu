#!/usr/bin/env nu

def nix-files [] {
  glob **/*.nix | where { |file| not (($file | path split) | any { |part| $part == "nixpkgs" }) }
}

def main [] {
  for file in (nix-files) {
    let result = (do { ^deadnix -e -f $file } | complete)

    if ($result.stderr | str trim) != "" {
      print $result.stderr
    }
  }

  for file in (nix-files) {
    let result = (do { ^nixfmt $file } | complete)

    if ($result.stderr | str trim) != "" {
      print $result.stderr
    }
  }
}
