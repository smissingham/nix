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


def main [
  --image: string
] {
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

  # ensure dedicated krunvm volume exists if needed
  if $nu.os-info.name == "macos" {
    mk-darwin-volume "krunvm" "/Volumes/krunvm" "Case-sensitive APFS" 
  }

  print $"Recreating MicroVM: ($vm_id)"

  krunvm delete $vm_id | complete | ignore

  print $"Creating MicroVM from image: ($image)"
  krunvm create $image --name $vm_id

  print $"Starting MicroVM: ($vm_id)"
  exec krunvm start $vm_id /bin/bash -- -i
}
