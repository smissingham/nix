# Dendritic

Reusable Nix flake for Sean's shell, editor, container, and CLI tooling.

## Quick Install

Install bundled devtools:

```sh
nix profile add github:smissingham/nix?dir=dendritic#sm-bundle-devtools
```

## Layout

```text
.
├── darwin/             # Darwin-only tooling
│   ├── aerospace/
│   └── skhd/
├── modules/            # Shared tooling
│   ├── bundles/         # Bulk install packages
│   ├── cli/             # Standalone CLI tools and wrappers
│   ├── coding/          # Editor tooling
│   ├── containers/      # Dev container image and runner
│   ├── scripts/         # Shared generated shell scripts
│   └── shells/          # Shell entrypoints and shared shell config
└── flake.nix            # Dendritic flake entrypoint
```

## Discover

Show available outputs:

```sh
nix flake show github:smissingham/nix?dir=dendritic
```

Show package names:

```sh
nix eval github:smissingham/nix?dir=dendritic#packages.$(nix eval --impure --raw --expr builtins.currentSystem) --apply builtins.attrNames
```

## Install

Install a package:

```sh
nix profile add github:smissingham/nix?dir=dendritic#<package>
```

## Run

Run a package app:

```sh
nix run github:smissingham/nix?dir=dendritic#<package>
```

Run from repo root:

```sh
nix run ./dendritic#<package>
```

## Develop

Enter dev shell with bundled tools:

```sh
nix develop github:smissingham/nix?dir=dendritic
```
