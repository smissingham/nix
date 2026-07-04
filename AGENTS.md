# Building & Testing

- Helper aliases
  - `nxrebuild` tests the config for all hosts. Prefer this as it auto runs the formatters
  - `nxfmt` aggressively auto-formats all nix files recursively from current directory
  - `nxdotfiles` symlinks all /dotfiles into user home (auto runs after `nxrebuild switch`)

# Code Style

- Prefer flat inline structures wherever possible, do not move things to "let" bindings until truly necessary
- Always prefer left-to-right logical readability, use nix pipe-operators to help here
