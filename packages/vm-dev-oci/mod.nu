def get-dir [
  kind: string
] {
  let home = $env.HOME
  let env_name = $"XDG_($kind | str upcase)_HOME"

  let base = (
    $env
    | get --optional $env_name
    | default (match $nu.os-info.name {
      "macos" => ($home | path join "Library" "Application Support")
      "linux" => (match $kind {
        "data" => ($home | path join ".local" "share")
        _ => { error make { msg: $"Unsupported dir kind: ($kind)" } }
      })
      _ => { error make { msg: "Unsupported OS" } }
    })
  )

  let dir = ($base | path join $env.APP_NAME)
  mkdir $dir
  $dir
}

def mk-darwin-volume [
  vol_id: string # a stable unique identifier for this volume on the system
  mount_path: string # where to mount the volume on the host system
  type: string = "APFS" # Volume case sensitivity setting
  container: string = "disk3" # APFS container to put volume into, disk3 on macos is default disk
] {
  # check for existence of volume before continuing
  let exists = (
    ^diskutil apfs list
    | lines
    | any {|l| $l =~ $'Name:\s+($vol_id).*' }
  )

  # create if not exists
  if not $exists {
    ^diskutil apfs addVolume $container $type $vol_id
  } 
}

def mk-vm-volume [
  vm_id: string
  vol_name: string
  --container: string = "disk3"
] {
  # always ensure data path exists for vm data
  let path_app_data = (get-dir "data")
  let path_vm_data = ($path_app_data | path join $vm_id)
  mkdir $path_vm_data


  # compose unique volume id & path and dispatch to OS volume maker functions
  let vol_id = ([ $env.APP_NAME $vm_id $vol_name ] | str join '-')
  let vol_path = ($path_vm_data | path join $vol_name)
  match $nu.os-info.name {
    "macos" => { mk-darwin-volume $vol_id $vol_path }
    _ => { error make { ms: "Unsupported OS for mk-vm-volume"}}
  }

  return $vol_id
}


def --wrapped main [
  --image: string
  ...command: string # Optional command and arguments.
] {
  let command = if ($command | get --optional 0) == "--" { $command | skip 1 } else { $command }
  let home = "/root" # krunvm explicitly sets HOME=/root for command launches.
  let workspace = ($home | path join "workspace")
  let host_paths = ($env.HOST_PATHS | from json)
  # krunvm's macOS mount helper interpolates guest paths into a shell script.
  for relative in $host_paths {
    if ($relative !~ '^[a-zA-Z0-9_.-]+(/[a-zA-Z0-9_.-]+)*$') or ($relative | split row '/' | any {|part| $part in ["." ".."] }) or ($relative == "workspace") or ($relative | str starts-with "workspace/") {
      error make { msg: $"Invalid home-relative directory: ($relative)" }
    }
  }
  # A parent share already includes its descendants; never stack overlapping mounts.
  let shares = ($host_paths | uniq | where {|relative|
    not ($host_paths | any {|parent| $relative | str starts-with $"($parent)/" })
  })
  let volumes = ($shares | each {|relative|
    let source = ($env.HOME | path join $relative | path expand)
    if ($source | str contains ':') {
      error make { msg: $"krunvm volume paths cannot contain a colon: ($source)" }
    }
    mkdir $source
    if ($source | path type) != "dir" {
      error make { msg: $"Host share must be a directory: ($source)" }
    }
    ["--volume" $"($source):($home)/($relative)"]
  } | flatten)
  if (pwd | str contains ':') {
    error make { msg: "krunvm workspace paths cannot contain a colon" }
  }

  # ensure dedicated krunvm volume exists before importing the image
  if $nu.os-info.name == "macos" {
    mk-darwin-volume "krunvm" "/Volumes/krunvm" "Case-sensitive APFS"
  }

  let use_default_image = ($image | is-empty)
  let image = if $use_default_image {
    print "No --image provided; importing built default OCI image..."
    run-external $env.DEFAULT_OCI_IMAGE_IMPORT | str trim
  } else {
    $image
  }

  # organise vm / workspace identity info
  let workspace_name = (pwd | path basename)
  let workspace_hash = (pwd | hash sha256)
  let image_name = (
    $image 
    | split row '/' 
    | last 
    | split row ":" 
    | first
  )

  # compose stable vm identity from calling context
  let vm_id = (
    [
      $image_name
      ($workspace_name | str downcase)
      ($workspace_hash | str substring 0..7)
    ] 
    | str join "-"
  )

  print $"Recreating MicroVM: ($vm_id)"
  krunvm delete $vm_id | complete | ignore

  print $"Creating MicroVM from image: ($image)"
  # Recreate only the image root, never copy, reset, or chown shared home data.
  krunvm create $image --name $vm_id --workdir $workspace --volume $"(pwd):($workspace)" ...$volumes
  if $env.LAST_EXIT_CODE != 0 {
    error make { msg: "krunvm create failed" }
  }

  print $"Starting MicroVM: ($vm_id)"
  let shell = if $use_default_image { "/bin/sm-zsh" } else { "/bin/bash" }
  if ($command | is-empty) {
    exec krunvm start $vm_id $shell -- -i
  }
  exec krunvm start $vm_id ($command | first) -- ...($command | skip 1)
}
