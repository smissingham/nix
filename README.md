# Nix Configuration Repository Template

This repository provides a template for declarative configuration of NixOS and macOS systems using Nix flakes. It's designed to manage system, user, and application configurations in a structured and reproducible way.

## Repository Structure

```
.
├── dots/                   # Dotfiles and application configurations
│   ├── auto/               # Configurations to be automatically linked into XDG_CONFIG_HOME
│   └── modules/            # Dotfile setups that relate to toggleable nix modules (manually linked by module)
├── flakes/                 # Custom Nix flakes for things like editors or project templates
│   ├── nvim-smissingham/   # Sean Missingham's Neovim, wrapped in a self contained nix flake
│   └── overlays/           # Custom nix packages, bundled as a flake, usable as overlays to other flakes 
│   └── templates/          # Flake templates, for quick devenv inits
├── hosts/                  # Host-specific configurations (one directory per machine)
├── modules/                # Reusable Nix modules for configuring systems and home environments
│   ├── darwin/             # macOS-specific modules
│   ├── nixos/              # NixOS-specific modules
│   └── shared/             # Cross-platform modules for both NixOS and macOS
├── profiles/               # User-specific configurations (e.g., 'work' or 'personal' profiles)
└── projects/               # Mini projects related to my system configuration
```

### Key Directories

- **`hosts/`**: Contains the complete, host-specific system configurations for your different machines.
- **`modules/`**: Holds reusable configuration modules, organized by platform (`darwin`/`nixos`/`shared`), to keep your setup DRY.
- **`dots/`**: Manages your application dotfiles and configurations declaratively.
- **`flakes/`**: A place for custom Nix flakes, such as a fully configured editor setup or project templates.
- **`packages/`**: For any custom package definitions that aren't available in the official nixpkgs repository.
- **`profiles/`**: Allows you to define different user profiles with specific sets of tools and configurations.
- **`projects/`**: Contains Nix flakes for setting up development environments for your various projects.

## Automatic Dotfiles Linking

This setup automatically links dotfiles from the `dots/auto/` directory to your XDG config directory (`~/.config`) using GNU Stow. This is handled by a pre-configured Home Manager module.

### Adding New Dotfiles

To have a configuration for a new application automatically linked:

1.  Create a directory for your application in `dots/auto/`.
2.  Add your configuration files to that new directory.

    **Example:** To add a configuration for `my-app`, you would create `dots/auto/my-app/config.toml`. This will be automatically linked to `~/.config/my-app/config.toml`.

3.  Rebuild your system. The modules included in this repository will handle the rest.

## Automatic Shell Functions

Any shell scripts (`.sh` files) placed in the `dots/auto/shellfn` directory will be automatically sourced when your shell starts up. This is also handled by a pre-configured module.

### Adding New Shell Functions

1.  Create a new `.sh` file in the `dots/auto/shellfn/` directory.
2.  Add your shell functions to this file.
3.  Rebuild your system. The functions will be available in your new shell sessions.

## Installation

### Nix Darwin (macOS) Setup

1.  Install Nix:
    ```bash
    sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
    ```

2.  Close and restart your shell.

3.  Clone this repository:
    ```bash
    git clone <your-repository-url> MyNixConfig
    cd MyNixConfig
    ```

4.  Install the system flake using `nix-darwin`:
    ```bash
    nix build .#darwinConfigurations.<hostname>.system
    ./result/sw/bin/darwin-rebuild switch --flake .#<hostname>
    ```
    (Replace `<hostname>` with the name of your host configuration from the `hosts` directory).

### NixOS Setup

1.  During the NixOS installation, clone this repository into `/mnt/etc/nixos`.
2.  Run the installation command:
    ```bash
    nixos-install --flake /mnt/etc/nixos#<hostname>
    ```
    (Replace `<hostname>` with the name of your host configuration).
