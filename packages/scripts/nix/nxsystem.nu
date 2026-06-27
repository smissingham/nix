#!/usr/bin/env nu

def size-to-bytes [value: string, unit: string] {
  let multiplier = match $unit {
    "B" => 1
    "KiB" => 1024
    "MiB" => 1048576
    "GiB" => 1073741824
    "TiB" => 1099511627776
    _ => 1
  }

  (($value | into float) * $multiplier | math round)
}

def main [target: string = "/run/current-system", --limit: int = 50] {
  if not ($target | path exists) {
    print $"path not found: ($target)"
    print "usage: nxsystem [/run/current-system|/nix/var/nix/profiles/system|~/.nix-profile] --limit 50"
    exit 1
  }

  ^nix path-info -rSh $target
    | lines
    | where { |line| ($line | str trim) != "" }
    | parse --regex '^(?P<path>\S+)\s+(?P<size_value>\d+(?:\.\d+)?)\s+(?P<size_unit>\S+)$'
    | insert name { |row| $row.path | path basename | str replace --regex '^[0-9a-z]{32}-' '' }
    | insert size { |row| $"($row.size_value) ($row.size_unit)" }
    | insert bytes { |row| size-to-bytes $row.size_value $row.size_unit }
    | sort-by bytes --reverse
    | first $limit
    | select name size path
}
