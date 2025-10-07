flatten_single_dir() {
  local dir="$1"
  local extracted_dirs=$(find "$dir" -mindepth 1 -maxdepth 1 -type d)
  local dir_count=$(echo "$extracted_dirs" | grep -c .)
  if [ "$dir_count" -eq 1 ] && [ -n "$extracted_dirs" ]; then
    find "$extracted_dirs" -mindepth 1 -maxdepth 1 -exec mv {} "$dir"/ \;
    rmdir "$extracted_dirs"
  fi
}

deep_extract() {
  local source_dir="$1"
  local target_dir="$2"

  rm -rf "$target_dir"
  mkdir "$target_dir"

  fd -e zip . "$source_dir" -x unzip {} -d "$target_dir"

  flatten_single_dir "$target_dir"

  while [ $(find "$target_dir" -name "*.zip" -type f | wc -l) -gt 0 ]; do
    find "$target_dir" -name "*.zip" -type f | while read -r zipfile; do
      local basename=$(basename "$zipfile" .zip)
      local dirname=$(dirname "$zipfile")
      local target_subdir="$dirname/$basename"
      mkdir -p "$target_subdir"
      unzip -q "$zipfile" -d "$target_subdir"
      rm "$zipfile"
      flatten_single_dir "$target_subdir"
    done
  done
}
