# Building & Testing

- Helper aliases
  - `nxfmt` aggressively auto-formats all nix files recursively from current directory
  - `nxrebuild` tests the config for all hosts to ensure config works for all systems
  - `nxdotfiles` symlinks all /dotfiles into user home (auto runs after `nxrebuild switch`)
