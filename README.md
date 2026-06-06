# Nix

Personal Nix configuration for macOS and NixOS hosts.

## Contents

```text
.
├── dendritic/     # Shell, editor, CLI, and container tooling flake
├── dots/          # Dotfiles linked into user config directories
├── hosting/       # Self-hosted service configuration
├── hosts/         # Host-specific system configuration
├── lib/           # Shared helper functions
├── modules/       # Reusable Darwin, NixOS, and shared modules
├── profiles/      # User/profile configuration and private modules
└── flake.nix      # Repository entrypoint for Darwin and NixOS systems
```

## Hosts

- `coeus`: NixOS machine.
- `plutus`: macOS / nix-darwin machine.

## Notes

This repo is intended as a working personal system configuration.

It is not a generic template.
