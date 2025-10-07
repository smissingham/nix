watch_exec() {
  # Generic file watching and command execution utility
  # Patterns to ignore during file watching
  local ignore_patterns=(
    ".git/"
    ".*~$"         # Backup files ending with ~
    ".*\.swp$"     # Vim swap files
    ".*\.tmp$"     # Temporary files
    ".*/\.[0-9]+$" # Numbered temporary files like ./4913
    ".*/#.*#$"     # Emacs temporary files
    ".*/\.#.*$"    # Emacs lock files
  )

  local path="."
  local pattern=".*"
  local exec_command=()
  local debounce_delay=2 # Seconds to wait before executing after last change
  local string_separator="#--------------------------------------------------#"

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
    --path)
      path="$2"
      shift 2
      ;;
    --pattern)
      pattern="$2"
      shift 2
      ;;
    *)
      # Collect all other arguments for the actual command to execute
      exec_command+=("$1")
      shift
      ;;
    esac
  done

  # Check if we have a command to execute
  if [[ ${#exec_command[@]} -eq 0 ]]; then
    echo "Error: No command specified to execute"
    echo "Usage: watch_exec [--path PATH] [--pattern PATTERN] COMMAND"
    return 1
  fi

  # Function to check if a file should be ignored
  should_ignore() {
    local file="$1"
    local pattern_check
    for pattern_check in "${ignore_patterns[@]}"; do
      if [[ "$file" =~ $pattern_check ]]; then
        return 0 # Should ignore
      fi
    done
    return 1 # Should not ignore
  }

  # Function to run the actual command with debouncing
  run_exec_debounced() {
    local changed_file="$1"
    local debounce_file="/tmp/.watchexec_debounce.$$"
    local exec_pid_file="/tmp/.watchexec_pid.$$"

    # Create unique timestamp for this change
    local change_time=$(date +%s.%N)

    # Kill existing debounce process if it exists
    if [[ -f "$exec_pid_file" ]]; then
      local old_pid=$(cat "$exec_pid_file" 2>/dev/null)
      if [[ -n "$old_pid" ]] && kill -0 "$old_pid" 2>/dev/null; then
        kill "$old_pid" 2>/dev/null
      fi
    fi

    # Write our timestamp to debounce file
    echo "$change_time" >"$debounce_file"

    # Start simple debounce process in background
    (
      echo $$ >"$exec_pid_file"

      # Sleep for the debounce delay
      sleep "$debounce_delay"

      # Check if our timestamp is still the latest (no newer changes occurred)
      local latest_change_time=$(cat "$debounce_file" 2>/dev/null || echo "0")

      if [[ "$change_time" == "$latest_change_time" ]]; then
        echo "$string_separator"
        echo "File changed: $changed_file"
        echo "Debounce period expired - Executing command"
        eval "${exec_command[*]}"

        echo "$string_separator"
      fi

      # Clean up
      rm -f "$exec_pid_file" "$debounce_file"
    ) &
  }

  echo "$string_separator"
  echo "Watch mode enabled"
  echo "Watching: $path"
  echo "Pattern: $pattern"
  echo "Command: ${exec_command[*]}"
  echo "Press Ctrl+C to stop watching"
  echo "$string_separator"

  # Start watching for changes
  if command -v inotifywait >/dev/null 2>&1; then
    inotifywait -r -m -e modify,create,delete,move --format '%w%f' "$path" 2>/dev/null |
      while read -r file; do
        if ! should_ignore "$file" && [[ "$file" =~ $pattern ]]; then
          run_exec_debounced "$file" &
        fi
      done
  elif command -v fswatch >/dev/null 2>&1; then
    fswatch "$path" 2>/dev/null | while read -r file; do
      if ! should_ignore "$file" && [[ "$file" =~ $pattern ]]; then
        run_exec_debounced "$file" &
      fi
    done
  else
    echo "Install inotify-tools (Linux) or fswatch (macOS) for watch functionality."
    return 1
  fi
}
