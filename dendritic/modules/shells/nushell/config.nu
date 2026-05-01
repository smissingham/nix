########## CONFIG ##########
$env.EDITOR = "sm-neovim"
$env.config.show_banner = false

# Direnv
$env.config = ($env.config | upsert hooks.env_change.PWD (
    ($env.config.hooks.env_change.PWD? | default [])
    | append [{ ||
        if (which direnv | is-empty) {
            return
        }

        direnv export json | from json | default {} | load-env
    }]
))



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
