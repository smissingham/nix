#!/bin/bash

# Purge Junk Files
# Runs on provided directory, or home dir if none provided
# Usage: jk <Optional:path>
jk() {
  local PATTERNS=(
    "*.DS_Store"
    "desktop.ini"
  )
  local TARGET_DIR="${1:-$HOME}"

  for P in "${PATTERNS[@]}"; do
    find "$TARGET_DIR" -name "$P" -print0 | xargs -0 -I {} sh -c 'echo "Deleted: {}"; rm -f "{}"'
  done
}

# Sources yubikey helper functions and env vars for use with sops yubikey setup
yk() {
  source "$NIX_CONFIG_HOME/profiles/smissingham/private/yubikey-sops/helpers.sh"
}

# Flatten copy prompts from nested structure to flat target
# TODO: Merge this with mcp management project
flatten_copy_prompts() {
  local source_dir="$XDG_CONFIG_HOME/genai/prompts"
  local target_dir="$XDG_CONFIG_HOME/opencode/command"

  # Remove existing target and recreate
  rm -rf "$target_dir"
  mkdir -p "$target_dir"

  # Find all files in source and copy with flattened names
  find "$source_dir" -type f -name "*.md" | while read -r file; do
    # Get relative path from source dir
    local rel_path="${file#$source_dir/}"
    # Replace slashes with underscores to flatten
    local flat_name="${rel_path//\//_}"
    ln -s "$file" "$target_dir/$flat_name"
  done
}

# Reload/Re-Source Configuration
# Reloads shell functions, tmux config, and aerospace config
# Usage: rl
rl() {
  # sh_reload
  # sh_source

  # rebuild and rewrite MCP config files
  pushd "$NIX_CONFIG_HOME/projects/mcp-configs" >/dev/null || return
  bun dist
  popd >/dev/null || return
  echo "Rebuilt and distributed MCP Configs"

  # copy central prompt lib to destinations
  flatten_copy_prompts

  # Host-specific configuration
  local HOSTNAME=$(hostname)
  case "$HOSTNAME" in
  "plutus")
    #rl_darwin
    ;;
  *)
    # Default case for unknown hosts
    echo "No specific configuration for host: $HOSTNAME"
    ;;
  esac
}

rl_darwin() {
  # reload aerospace from custom script defined in aerospace nix module
  # TODO: move this into the aerospace nix module
  build-and-reload-aerospace
  echo "Reloaded Aerospace"

  # skhd, kill the active pid and reload
  #pkill -f '/bin/skhd'
  #skhd -r
  #echo "Reloaded SKHD"

  # # re-source jankyborders settings
  # sh "$CONF/borders/bordersrc"
  # echo "Reloaded Borders"
}
