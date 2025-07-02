#!/bin/bash

PATTERNS=(
    "*.DS_Store"
)

TARGET_DIR="${1:-$HOME}"

for P in "${PATTERNS[@]}"; do
    find "$TARGET_DIR" -name "$P" -print0 | xargs -0 -I {} sh -c 'echo "Deleted: {}"; rm -f "{}"'
done
