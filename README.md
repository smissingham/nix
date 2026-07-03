Nix flake for reusable packages and personal host configuration.

## Standalone Packages

Portable outputs usable directly from the flake on any system with Nix CLI.

Enter the default (minimal) dev shell:

```sh
nix develop github:smissingham/nix
```

Enter the full (maximal) dev shell:

```sh
nix develop github:smissingham/nix#full
```

Show available packages:

```sh
nix flake show github:smissingham/nix --all-systems | sed -n '/packages/,/devShells/p'
```

Install full devtools bundle:

```sh
nix profile add github:smissingham/nix#sm-cli-devtools
```

### Enable Nix "experimental-features"

If these commands fail on experimental features, enable flakes once:

```sh
mkdir -p ~/.config/nix && printf 'experimental-features = nix-command flakes pipe-operators\n' >> ~/.config/nix/nix.conf
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
