#!@nushell@/bin/nu

def check-hosts [attr: string, build_attr: string] {
  let hosts = (^nix eval $".#($attr)" --apply builtins.attrNames --json --impure | from json)

  $hosts | each { |host|
    ^nix build $".#($attr).($host).($build_attr)" --dry-run --show-trace --impure
  }
}

def main [] {
  cd $env.NIX_CONFIG_HOME
  check-hosts darwinConfigurations system
  check-hosts nixosConfigurations config.system.build.toplevel
}
