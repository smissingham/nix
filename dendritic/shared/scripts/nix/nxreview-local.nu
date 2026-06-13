#!@nushell@/bin/nu

def main [] {
  let system = (^uname | str downcase | str trim)
  ^nixpkgs-review rev HEAD --print-result --systems $system
}
