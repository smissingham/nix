#!@nushell@/bin/nu

def main [package_file: string = "./package.nix", args: string = "{}"] {
  if not ($package_file | path exists) {
    print $"Error: Package file '($package_file)' not found"
    exit 1
  }

  with-env { NIXPKGS_ALLOW_UNFREE: "1" } {
    ^nix-build --quiet --no-build-output -E $"(import <nixpkgs> {}).callPackage ($package_file) ($args)"
  }
}
