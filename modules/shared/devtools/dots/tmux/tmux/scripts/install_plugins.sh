#!/usr/bin/env bash

# Define tmux config directory
TMUX_DIR="$HOME/.config/tmux"
TPM_DIR="$TMUX_DIR/plugins/tpm"
LOG_FILE="$TMUX_DIR/scripts/install_plugins.log"

# Delete log file if it exists
rm -f "$LOG_FILE"

# Function to log messages to both console and log file
log() {
  echo "$@" | tee -a "$LOG_FILE"
}

log "Starting tmux plugin installation at $(date)"

# Create plugins directory if it doesn't exist
mkdir -p "$TMUX_DIR/plugins"
log "Created plugins directory: $TMUX_DIR/plugins"

# Clone TPM if not already installed
if [ ! -d "$TPM_DIR" ]; then
  log "Installing TPM (Tmux Plugin Manager)..."
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR" 2>&1 | tee -a "$LOG_FILE"
  log "TPM installation complete"
else
  log "TPM already installed at $TPM_DIR"
fi

# Install plugins
log "Installing tmux plugins..."
"$TPM_DIR/bin/install_plugins" 2>&1 | tee -a "$LOG_FILE"

log "Tmux plugin installation complete at $(date)!"
log "Log file available at: $LOG_FILE"
