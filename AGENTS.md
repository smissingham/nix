# Building & Testing

- Helper aliases
  - `nxrebuild` tests the config for all hosts. Prefer this as it auto runs the formatters
  - `nxfmt` aggressively auto-formats all nix files recursively from current directory
  - `nxdotfiles` symlinks all /dotfiles into user home (auto runs after `nxrebuild switch`)
