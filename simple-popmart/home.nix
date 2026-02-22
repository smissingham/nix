# ---------------------------------------------------------------------------
# home.nix - Your personal environment
#
# This file controls everything specific to YOU as a user (not the system):
#   - Packages installed in your user profile
#   - Shell setup (zsh, aliases, plugins)
#   - Git identity
#   - Developer tools
#   - macOS keybindings
# ---------------------------------------------------------------------------
{ pkgs, lib, config, ... }:

# ---------------------------------------------------------------------------
# SHELL ALIASES
# Defined here once and shared between zsh and bash.
# ---------------------------------------------------------------------------
let
  shellAliases = {
    # General
    q    = "exit";
    cl   = "clear";
    ls   = "eza";                  # eza is a better ls
    ll   = "eza -l";
    la   = "eza -la";
    clip = "xclip -selection clipboard";
    t    = "open -a ghostty";      # open terminal

    # Neovim
    v      = "nvim";
    vclear = "rm -rf ~/.local/share/nvim*";

    # Tmux
    tm = "tmux new-session -A -s";

    # Nix shortcuts
    nxrepl  = "nix repl --expr 'import <nixpkgs>{}'";
    nxfmt   = "find . -name '*.nix' -exec nixfmt {} \\;";
    nxr     = "pushd ~/Documents/Nix; nxfmt; git add .; sudo darwin-rebuild switch --flake .#popmart --impure --show-trace; popd";
    nxu     = "pushd ~/Documents/Nix; find . -name \"flake.lock\" -delete; nix flake update; popd";
    nxgc    = "nix-collect-garbage --delete-old";
    nxshell = "nix-shell -p";

    # Python
    pyenv = "python3 -m venv .venv";

    # AeroSpace: fuzzy-find and focus a window
    fw = "aerospace list-windows --all | fzf --bind 'enter:execute(bash -c \"aerospace focus --window-id {1}\")+abort'";
  };
in

{
  # ---------------------------------------------------------------------------
  # HOME BASICS
  # Don't change stateVersion - it's a migration marker, not a version pin.
  # ---------------------------------------------------------------------------
  home.stateVersion  = "24.11";
  home.username      = "regionativo";
  home.homeDirectory = "/Users/regionativo";

  # ---------------------------------------------------------------------------
  # YOUR PACKAGES
  # Everything listed here gets installed into your user profile.
  # Add or remove things here and run `nxr`.
  # ---------------------------------------------------------------------------
  home.packages = with pkgs; [

    # ----- AI Tools -----
    claude-code   # Claude Code CLI

    # ----- Editor & Dev Tools -----
    neovim
    lazygit       # git TUI
    fd            # better `find`
    ripgrep       # better `grep`
    gcc           # C compiler (needed by some neovim plugins)
    gnumake       # make (needed by some neovim plugins)

    # ----- Language Runtimes (needed by neovim plugins) -----
    python312
    nodejs_20
    uv            # fast Python package manager

    # ----- Language Servers (for neovim) -----
    lua-language-server          # Lua
    nixd                         # Nix
    taplo                        # TOML
    vscode-langservers-extracted # HTML, CSS, JSON, JS
    prettierd                    # code formatter

    # ----- Neovim plugin requirements -----
    tree-sitter
    dwt1-shell-color-scripts  # colorful shell scripts for neovim dashboard
  ];

  # ---------------------------------------------------------------------------
  # GIT
  # ---------------------------------------------------------------------------
  programs.git = {
    enable = true;
    settings.user.name  = "Jose Paez";
    settings.user.email = "jopaez@gmail.com";
  };

  # ---------------------------------------------------------------------------
  # ZSH (your main shell)
  # ---------------------------------------------------------------------------
  programs.zsh = {
    enable            = true;
    enableCompletion  = true;
    dotDir            = config.home.homeDirectory;  # keep .zshrc in home folder
    shellAliases      = shellAliases;
    syntaxHighlighting.enable = true;

    history.size = 10000;

    # initContent runs at shell startup (after everything else is loaded)
    initContent = ''
      source ~/.p10k.zsh               # Powerlevel10k prompt config
      source ~/.secrets/api-keys.env   # your API keys (not tracked in git)

      # Auto-start Claude Code when opening a terminal in your Obsidian vault
      if [[ "$PWD" == "/Users/regionativo/Documents/POPMART/POPMART" ]] && [[ -z "$CLAUDE_STARTED" ]]; then
          export CLAUDE_STARTED=1
          claude
      fi
    '';

    plugins = [
      # Powerlevel10k: the prompt theme (shows git status, time, etc.)
      {
        name = "powerlevel10k";
        src  = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      # Autosuggestions: suggests previous commands as you type
      {
        name = "zsh-autosuggestions";
        src  = pkgs.fetchFromGitHub {
          owner  = "zsh-users";
          repo   = "zsh-autosuggestions";
          rev    = "v0.4.0";
          sha256 = "0z6i9wjjklb4lvr7zjhbphibsyx51psv50gm07mbb0kj9058j6kc";
        };
      }
    ];
  };

  # ---------------------------------------------------------------------------
  # BASH (kept enabled as a fallback shell)
  # ---------------------------------------------------------------------------
  programs.bash = {
    enable           = true;
    enableCompletion = true;
    shellAliases     = shellAliases;
  };

  # ---------------------------------------------------------------------------
  # DIRENV - automatically loads .envrc files when you cd into a folder
  # Great for per-project environment variables and nix shells.
  # ---------------------------------------------------------------------------
  programs.direnv = {
    enable               = true;
    enableZshIntegration = true;
    nix-direnv.enable    = true; # faster nix integration for direnv
  };

  # ---------------------------------------------------------------------------
  # ZOXIDE - smarter `cd` that learns your most-visited folders
  # Use `z foldername` instead of typing the full path
  # ---------------------------------------------------------------------------
  programs.zoxide = {
    enable               = true;
    enableZshIntegration = true;
  };

  # ---------------------------------------------------------------------------
  # XDG - standard folder locations ($XDG_CONFIG_HOME, etc.)
  # ---------------------------------------------------------------------------
  xdg = {
    enable = true;
    userDirs.extraConfig = {
      XDG_GAME_DIR      = "${config.home.homeDirectory}/Documents/Games";
      XDG_GAME_SAVE_DIR = "${config.home.homeDirectory}/Documents/GameSaves";
    };
  };

  # ---------------------------------------------------------------------------
  # MACOS KEYBINDINGS
  # Fixes Home/End keys to jump to beginning/end of line instead of document.
  # ---------------------------------------------------------------------------
  targets.darwin.keybindings = {
    "\UF729" = "moveToBeginningOfLine:"; # Home key
    "\UF72B" = "moveToEndOfLine:";       # End key
  };
}
