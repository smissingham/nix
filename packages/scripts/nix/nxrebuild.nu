#!/usr/bin/env nu

# Check every host under one flake output attr.
def check-host-output [attr: string, build_attr: string] {
  let hosts = (^nix eval $".#($attr)" --apply builtins.attrNames --json | from json)

  $hosts | each { |host|
    ^nix build $".#($attr).($host).($build_attr)" --dry-run --show-trace
  }
}

# Check all configured Darwin and NixOS hosts.
def check-all-hosts [] {
  check-host-output darwinConfigurations system
  let darwin_exit_code = $env.LAST_EXIT_CODE

  if $darwin_exit_code != 0 {
    return $darwin_exit_code
  }

  check-host-output nixosConfigurations config.system.build.toplevel
  $env.LAST_EXIT_CODE
}

# Apply this host's system configuration.
def switch-local-host [] {
  let hostname = (sys host | get hostname)
  let flake = $".#($hostname)"

  let rebuild_command = if (sys host | get name) == "Darwin" {
    "darwin-rebuild"
  } else {
    "nixos-rebuild"
  }

  ^sudo $rebuild_command switch --flake $flake --show-trace
  $env.LAST_EXIT_CODE
}

# Check all hosts by default, or switch this host when requested.
def main [action: string = "check"] {
  if not ($action in ["check", "switch"]) {
    print "usage: nxrebuild [check|switch]"
    exit 1
  }

  cd $env.NIX_CONFIG_HOME
  ^nxfmt

  let git_index_backup = (^mktemp)
  ^cp .git/index $git_index_backup
  ^git add .

  let rebuild_exit_code = if $action == "check" {
    check-all-hosts
  } else {
    switch-local-host
  }

  ^cp $git_index_backup .git/index
  ^rm $git_index_backup

  if $rebuild_exit_code != 0 {
    exit $rebuild_exit_code
  }

  if $action == "switch" {
    ^nxdotfiles
  }
}
