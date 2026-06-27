Nix flake for reusable packages and personal host configuration.

## Standalone Packages

Portable outputs usable directly from the flake on any system with Nix CLI.

Enter the default dev shell:

```sh
nix develop --refresh github:smissingham/nix
```

Show available packages:

```sh
nix flake show --refresh github:smissingham/nix#packages
```

Install full devtools bundle:

```sh
nix profile add --refresh github:smissingham/nix#sm-devtools
```

### Enable Nix "experimental-features"

If these commands fail on experimental features, enable flakes once:

```sh
mkdir -p ~/.config/nix && printf 'experimental-features = nix-command flakes\n' >> ~/.config/nix/nix.conf
```

## Contents

Some directories define portable flake outputs; the rest support personal host configuration.

```text
Portable flake outputs:
packages/      # Standalone packages and dev shell bundles
wrappers/      # Wrapper module definitions used by packages and host config

Personal host config:
modules/       # Abstracted Nix modules for Darwin & NixOS
hosts/         # Host-system & user configurations
dotfiles/      # Personal dotfiles (auto stowed to user path)
```
