#!@nushell@/bin/nu

def main [...args: string] {
  let system = (^uname | str downcase | str trim)
  ^nixpkgs-review pr --post-result --systems $system ...$args
}
