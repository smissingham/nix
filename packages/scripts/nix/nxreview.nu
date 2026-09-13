def --wrapped main [...args: string] {
  let args = if ($args | take while { $in != "--" } | any { $in =~ '^--systems(=|$)' }) {
    $args
  } else {
    # parse nix config to hashmap
    let config = (
      ^nix config show
      | lines
      | parse --regex '^\s*(?<key>[^=]+?)\s*=\s*(?<value>.*)$'
      | transpose --header-row --as-record
    )

    # current system first, obviousleh
    let current_system = ($config | get "system")

    # extra supported systems on current platform
    let extra_platforms = (
      $config
      | get "extra-platforms"
      | str trim
      | split row --regex '\s+'
    )

    # grab available systems from connected builders
    let builder_systems = (
      ^cat /etc/nix/machines
      | lines
      | where { str trim | is-not-empty }
      | first
      | split row --regex '\s+'
      | get 1
    )

    # concat all found, sort and unique them
    let all_systems = (
      [ $current_system ]
      | append $extra_platforms
      | append $builder_systems
      | sort
      | uniq
    )

    # concat a string to pass into subsequent cli commands
    let systems_str = $all_systems | str join " "

    [...$args --systems $systems_str]
  }

  let checkout = (^git rev-parse --show-toplevel | complete)
  let root = ($checkout.stdout | str trim)
  let is_nixpkgs = ($checkout.exit_code == 0
    and ($root | path join pkgs/top-level/all-packages.nix | path exists)
    and ($root | path join lib/default.nix | path exists))
  let tmpdir = if $is_nixpkgs { null } else {
    do --capture-errors { ^mktemp -d } | str trim
  }

  let exit_code = try {
    if $tmpdir != null {
      do --capture-errors { ^git clone https://github.com/NixOS/nixpkgs --depth=1 $tmpdir }
    }
    cd ($tmpdir | default $root)
    let command = ([nix run .#nixpkgs-review -- ...$args]
      | each {|arg| if $arg =~ '^[a-zA-Z0-9_./:=+-][a-zA-Z0-9_./#:=+-]*$' { $arg } else { $arg | to nuon } }
      | str join " ")
    print $command
    ^nu --no-config-file -c $command
    $env.LAST_EXIT_CODE
  } catch {|err|
    print --stderr $err.msg
    $err.exit_code? | default 1
  }

  if $tmpdir != null { rm --recursive --force $tmpdir }
  exit $exit_code
}
