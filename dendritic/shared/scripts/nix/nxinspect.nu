#!@nushell@/bin/nu

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

def bytes-to-size [bytes: filesize] {
  let units = [B KiB MiB GiB TiB]
  let value = ($bytes | into int)
  let unit_index = ([$value 1024 1048576 1073741824 1099511627776]
    | enumerate
    | where { |row| $value >= $row.item }
    | last
    | get index)
  let unit = ($units | get $unit_index)
  let divisor = ([1 1024 1048576 1073741824 1099511627776] | get $unit_index)

  if ($unit == "B") {
    $"($value) B"
  } else {
    $"(($value / $divisor) | into float | math round --precision 1) ($unit)"
  }
}

def linked-libs-darwin [program_path: string] {
  let result = (^otool -L $program_path | complete)
  if $result.exit_code != 0 {
    return []
  }

  $result.stdout
    | lines
    | skip 1
    | each { |line| $line | str trim | split row " " | first }
    | where { |lib| ($lib | str trim) != "" }
}

def linked-libs-linux [program_path: string] {
  let result = (^ldd $program_path | complete)
  if $result.exit_code != 0 {
    return []
  }

  $result.stdout
    | lines
    | each { |line|
        let trimmed = ($line | str trim)
        if ($trimmed | str contains "=>") {
          $trimmed | split row "=>" | get 1 | str trim | split row " " | first
        } else {
          $trimmed | split row " " | first
        }
      }
    | where { |lib| ($lib | str starts-with "/") }
}

def linked-libs [program_path: string] {
  match (^uname | str downcase | str trim) {
    "darwin" => { linked-libs-darwin $program_path }
    "linux" => { linked-libs-linux $program_path }
    _ => []
  }
}

def main [app?: string] {
  if ($app == null) {
    print "usage: nxinspect <program>"
    exit 1
  }

  let matches = (which $app)
  if ($matches | is-empty) {
    print $"program not found: ($app)"
    exit 1
  }

  let match = ($matches | first)
  let match_path = if (($match.path? | default "") != "") {
    $match.path
  } else {
    $match.external? | default ""
  }
  let program_path = (^realpath $match_path | str trim)

  let deps = (^nix path-info -rSh $program_path
    | lines
    | where { |line| ($line | str trim) != "" }
    | parse --regex '^(?P<path>\S+)\s+(?P<size_value>\d+(?:\.\d+)?)\s+(?P<size_unit>\S+)$'
    | insert name { |row| $row.path | path basename | str replace --regex '^[0-9a-z]{32}-' '' }
    | insert size { |row| $"($row.size_value) ($row.size_unit)" }
    | insert bytes { |row| size-to-bytes $row.size_value $row.size_unit }
    | sort-by bytes --reverse)
  let dependency_count = (($deps | length) - 1)

  let binary_size = (bytes-to-size (ls $program_path | first | get size))
  let linked_libs = (linked-libs $program_path)

  print $"Program: ($app)"
  print $"Binary size: ($binary_size)"
  print $"Linked libs: ($linked_libs | length)"
  $linked_libs | each { |lib| print $"  - ($lib)" }
  print ""
  print $"Dependencies: ($dependency_count)"

  $deps | select name size path
}
