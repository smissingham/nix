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

# Reload Configuration
# Reloads shell functions, tmux config, and aerospace config
# Usage: rl
rl() {
  # short var for config dir
  CONF="$XDG_CONFIG_HOME"

  # reload shell functions
  SHELL_FUNCS_DIR=$CONF/shellfn
  if [ -d "$SHELL_FUNCS_DIR" ]; then
    for file in "$SHELL_FUNCS_DIR"/*.sh; do
      source "$file"
    done
  fi

  # reload tmux
  tmux source "$CONF"/tmux/tmux.conf

  # reload aerospace from custom script defined in aerospace nix module
  build-and-reload-aerospace
}

git_files_unstaged() {
  git status --porcelain | grep '^.[M]' | cut -c4- | grep -E '\.(json|groovy)$'
}
