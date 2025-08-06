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
