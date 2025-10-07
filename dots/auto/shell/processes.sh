#!/bin/bash

# Process list function
# Usage: psl <process_name>
# Example: psl "node" - lists all processes matching "node"
# Example: psl "python" - lists all processes matching "python"
# Example: psl "1234" - lists process with PID 1234
psl() {
  local search_term="$1"
  if [ -z "$search_term" ]; then
    echo "Usage: psl <process_name>"
    return 1
  fi

  local processes=$(ps aux | grep "$search_term" | grep -v grep)
  if [ -n "$processes" ]; then
    echo "Processes matching '$search_term':"
    echo "$processes"
  else
    echo "No processes found matching: $search_term"
  fi
}

# Process killer function
# Usage: psk <process_name>
# Example: psk "node" - kills all processes matching "node"
# Example: psk "python" - kills all processes matching "python"
# Example: psk "1234" - kills process with PID 1234
psk() {
  local search_term="$1"
  if [ -z "$search_term" ]; then
    echo "Usage: psk <process_name>"
    return 1
  fi

  local processes=$(ps aux | grep "$search_term" | grep -v grep)
  local pids=$(echo "$processes" | awk '{print $2}')

  if [ -n "$pids" ]; then
    echo "Processes that will be killed:"
    echo "$processes"
    echo ""
    echo "PIDs to kill: $pids"
    echo -n "Are you sure you want to kill these processes? (y/N): "
    read -r confirmation

    if [[ "$confirmation" =~ ^[Yy]$ ]]; then
      echo "Killing processes..."
      ps aux | grep "$search_term" | grep -v 'grep' | awk '{print $2}' | xargs kill -9
      echo "Done."
    else
      echo "Operation cancelled."
    fi
  else
    echo "No processes found matching: $search_term"
  fi
}
