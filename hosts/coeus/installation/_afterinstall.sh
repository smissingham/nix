#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# Safety Check: Prevent running as root or with sudo
# ─────────────────────────────────────────────────────────────────────────────
if [ "$EUID" -eq 0 ] || [ -n "$SUDO_USER" ]; then
    echo "This script should not be run as root or with sudo."
    exit 1
fi

# ─────────────────────────────────────────────────────────────────────────────
# Ensure ~/Documents is owned by the current user
# This can fix ownership issues caused by running installers as root
# ─────────────────────────────────────────────────────────────────────────────
DOCS_DIR="$HOME/Documents"
OWNER=$(stat -c '%U' "$DOCS_DIR")

if [ "$OWNER" != "$USER" ]; then
    echo "Changing ownership of $DOCS_DIR to $USER..."
    chown -R "$USER:users" "$DOCS_DIR"
else
    echo "$DOCS_DIR is already owned by $USER. Skipping chown."
fi

# ─────────────────────────────────────────────────────────────────────────────
# Create symlinks for dotfolders to persist them inside ~/Documents
# ─────────────────────────────────────────────────────────────────────────────
dotfolders=(
    ".ssh"
    ".steam"
)

for folder in "${dotfolders[@]}"; do
    src="$HOME/Documents/$folder"
    dest="$HOME/$folder"

    # Create source directory if it doesn't exist
    if [ ! -d "$src" ]; then
        echo "Creating $src..."
        mkdir -p "$src"
    fi

    # Create symlink if not already present
    if [ -L "$dest" ]; then
        echo "Symlink already exists: $dest"
    elif [ -e "$dest" ]; then
        echo "WARNING: $dest already exists and is not a symlink. Skipping."
    else
        echo "Creating symlink: $dest -> $src"
        ln -s "$src" "$dest"
    fi
done