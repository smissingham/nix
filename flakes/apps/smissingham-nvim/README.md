# smissingham-nvim

Sean Missingham's Neovim configuration optimized for development with AI assistance and LSP support.

[![Neovim](https://img.shields.io/badge/Neovim-0.9%2B-green)](https://neovim.io/)
[![Nix](https://img.shields.io/badge/Nix-reproducible-blue)](https://nixos.org/)

## Installation

While you could copy the contents of the nvim config folder, this repo
is designed to be run temporarily or installed **as a Nix Flake**

### Nix Flake Run Anywhere (No Install)

To run this flake directly off github in a temp shell

```
nix run --extra-experimental-features "nix-command flakes" "github:smissingham/nix?dir=flakes/apps/smissingham-nvim"
```

To install it into your nix profile

```

nix profile add --extra-experimental-features "nix-command flakes" "github:smissingham/nix?dir=flakes/apps/smissingham-nvim"
```

### Nix System Flake Installation

If you're using Nix like I am to manage your system configuration, you can import
this flake and install the provided "smissingham-nvim" as a system package like any other

I got a little creative myself and wrapped it in a nix module which
directly references this flake instead of declaring it as an input in my root flake

[See Here for My Nix Module](../../modules/shared/devtools/smissingham-nvim.nix)

## Configuration Structure

```
nvim/
├── init.lua                 # Main configuration entry point
├── lua/
│   ├── config/
│   │   ├── keymaps.lua      # Key mappings
│   │   ├── options.lua      # Vim options
│   │   ├── plugins.lua      # Plugin manager setup
│   │   └── commands.lua     # Custom commands
│   └── plugins/             # Individual plugin configurations
└── lazy-lock.json           # Plugin lock file
```

## Key Mappings

Default key mappings (leader key is `\`):

## Features

- **Modern Plugin Management**: Uses [lazy.nvim](https://github.com/folke/lazy.nvim) for fast plugin loading
- **AI Integration**: Built-in support for LLM tools through MCPHub, Avante, and Opencode
- **Language Server Support**: Preconfigured LSP for multiple languages
- **Smart Completion**: Advanced completion engine with blink.cmp
- **Git Integration**: Full Git integration with Gitsigns and Diffview
- **Nix Packaging**: Reproducible environment with Nix flakes
- **Beautiful Themes**: Multiple theme options including Catppuccin, Tokyo Night, and Kanagawa
