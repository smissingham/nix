########## CONFIG ##########
$env.config.show_banner = false



########## PLUGINS ##########
def autoload-path [name: string] {
    let autoload_dir = $nu.data-dir | path join "vendor/autoload"
    mkdir $autoload_dir
    $autoload_dir | path join $"($name).nu"
}

# Atuin
atuin init nu | save -f (autoload-path "atuin")

# Television
tv init nu | save -f (autoload-path "tv")

# Zoxide
zoxide init nushell | save -f (autoload-path "zoxide")
