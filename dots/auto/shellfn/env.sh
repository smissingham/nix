#!/bin/bash

# Purge Junk Files
# Runs on provided directory, or home dir if none provided
# Usage: jk <Optional:path>
jk() {
  local PATTERNS=(
    "*.DS_Store"
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

# Reload/Re-Source Configuration
# Reloads shell functions, tmux config, and aerospace config
# Usage: rl
rl() {
  # short var for config dir
  CONF="$XDG_CONFIG_HOME"

  # re-source shell functions
  SHELL_FUNCS_DIR=$CONF/shellfn
  if [ -d "$SHELL_FUNCS_DIR" ]; then
    for file in "$SHELL_FUNCS_DIR"/*.sh; do
      source "$file"
      echo "Re-Sourced $file"
    done
  fi

  # reload tmux
  tmux source "$CONF"/tmux/tmux.conf

  # rebuild and rewrite MCP config files
  pushd "$NIX_CONFIG_HOME/projects/mcp-configs" || return
  bun dist
  popd || return
  echo "Rebuilt and distributed MCP Configs"

  # Host-specific configuration
  local HOSTNAME=$(hostname)
  case "$HOSTNAME" in
  "plutus")
    rl_darwin
    ;;
  *)
    # Default case for unknown hosts
    echo "No specific configuration for host: $HOSTNAME"
    ;;
  esac
}

rl_darwin() {
  # reload aerospace from custom script defined in aerospace nix module
  build-and-reload-aerospace
  echo "Reloaded Aerospace"

  # skhd, kill the active pid and reload
  pkill -f '/bin/skhd'
  skhd -r
  echo "Reloaded SKHD"

  # re-source jankyborders settings
  sh "$CONF/borders/bordersrc"
  echo "Reloaded Borders"
}

git_files_unstaged() {
  git status --porcelain | grep '^.[M]' | cut -c4- | grep -E '\.(json|groovy)$'
}
