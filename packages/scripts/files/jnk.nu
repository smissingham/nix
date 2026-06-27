#!@nushell@/bin/nu

const file_patterns = [
  '^\.DS_Store$' # macos finder junk
  '^Thumbs\.db$' # OS thumbnail stuff
  '^result$' # nix build outputs

]

const directory_patterns = [
  '^__pycache__$'
]

def find-junk [patterns: list<string>, kind: string] {
  mut entries = []

  for pattern in $patterns {
    $entries = ($entries | append (^fd --hidden --no-ignore --type $kind --color never $pattern | lines))
  }

  $entries | uniq
}

def delete-empty-directories [] {
  mut deleted = 0

  loop {
    let empty_directories = (^fd --hidden --no-ignore --type empty --type directory --color never | lines)

    if ($empty_directories | is-empty) {
      break
    }

    $empty_directories | each { |directory| rm --recursive --force $directory } | ignore
    $deleted = ($deleted + ($empty_directories | length))
  }

  $deleted
}

def main [] {
  let files = (find-junk $file_patterns f)
  let directories = (find-junk $directory_patterns d)

  $files | each { |file| rm --force $file } | ignore
  $directories | each { |directory| rm --recursive --force $directory } | ignore
  let empty_directories = (delete-empty-directories)

  print $"deleted files: (($files | length))"
  print $"deleted directories: (($directories | length))"
  print $"deleted empty directories: ($empty_directories)"
}
