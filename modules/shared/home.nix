# ----- HOME CONFIGURATION TO APPLY ON ALL (DARWIN + NIXOS) SYSTEMS -----#
{
  config,
  lib,
  pkgs,
  mainUser,
  ...
}:
let
  alacrittyColors = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "alacritty";
    rev = "f6cb5a5c2b404cdaceaff193b9c52317f62c62f7";
    hash = "sha256-H8bouVCS46h0DgQ+oYY8JitahQDj0V9p2cOoD4cQX+Q=";
  };

  hostRebuildCli = (if pkgs.stdenv.isDarwin then "darwin-rebuild" else "sudo nixos-rebuild");

  shellAliases = {
    cl = "clear";
    ll = "eza -l";
    la = "eza -la";
    clip = "xclip -selection clipboard";
    nxrepl = "nix repl --expr 'import <nixpkgs>{}'";
    nxfmt = "find . -name '*.nix' -exec nixfmt {} \\;";
    nxrbs = "pushd $NIX_CONFIG_HOME; nxfmt; git add .; ${hostRebuildCli} switch --flake .#$(hostname) --show-trace; popd";
    nxcommit = ''nxfmt; git add $NIX_CONFIG_HOME; git commit $NIX_CONFIG_HOME -m "$(nix-host-rebuild list-generations | grep current)";'';
    nxgc = "nix-collect-garbage --delete-old";
    nxshell = "nix-shell -p $1";

    # TODO: Staging Area. Once happy this is mature, move it up among the rest
    nxbuild = ''nix-build -E 'with import <nixpkgs> {}; callPackage '"$1"' {}' --show-trace'';
    nv = "nix run $NIX_CONFIG_HOME/flakes/nixvim# -- $1";
    dwrb = "nxfmt; git add .; darwin-rebuild $1 --flake $NIX_CONFIG_HOME#$(hostname) --show-trace"; # merge with nxrbs?

    # TODO: Keep Empty. Temp aliases for currently common activities that shouldnt stay common

  };
in
{
  users.users.${mainUser.username} = {
    name = mainUser.username;
    home = (if pkgs.stdenv.isDarwin then "/Users/" else "/home/") + mainUser.username;
  };
  home-manager = {
    # Allow unfree packages
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-bak";
    users.${mainUser.username} =
      { pkgs, ... }:
      {
        home = {
          username = mainUser.username;
          homeDirectory = (if pkgs.stdenv.isDarwin then "/Users/" else "/home/") + mainUser.username;
          file = {
            ".continue" = {
              source = ../../dots/.continue;
              recursive = true;
            };
          };
        };

        xdg = {
          enable = true;
          userDirs = {
            extraConfig = {
              XDG_GAME_DIR = "${config.home.homeDirectory}/Media/Games";
              XDG_GAME_SAVE_DIR = "${config.home.homeDirectory}/Media/GameSaves";
            };
          };
        };

        programs.git = {
          userName = mainUser.name;
          userEmail = mainUser.email;
        };

        programs.bash = {
          enable = true;
          enableCompletion = true;
          shellAliases = shellAliases;
        };

        programs.direnv = {
          enable = true;
          enableZshIntegration = true;
          nix-direnv.enable = true;
        };

        programs.zsh = {
          enable = true;
          enableCompletion = true;
          shellAliases = shellAliases;
          autosuggestion.enable = true;
          syntaxHighlighting.enable = true;
          initExtra = "source ~/.p10k.zsh";

          history = {
            size = 10000;
          };

          plugins = [
            {
              name = "powerlevel10k";
              src = pkgs.zsh-powerlevel10k;
              file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
            }
          ];
        };

        programs.alacritty = {
          enable = true;
          settings = {
            general.import = [ "${alacrittyColors}/catppuccin-mocha.toml" ];
            font = {
              size = 13; # 14 creates glitches on p10k prompt
              normal.family = lib.mkForce "MesloLGS Nerd Font"; # p10k recommends
            };
            env = {
              TERM = "xterm-256color";
            };
            window = {
              opacity = lib.mkForce 0.975;
              padding.x = 12;
              padding.y = 12;
            };
          };
        };

        programs.tmux = {
          enable = true;
          clock24 = true;
          plugins = with pkgs; [
            tmuxPlugins.catppuccin
            tmuxPlugins.better-mouse-mode
            tmuxPlugins.sensible
            tmuxPlugins.vim-tmux-navigator
          ];
          extraConfig = ''
            set -g default-terminal "tmux-256color"
            set -ag terminal-overrides ",xterm-256color:RGB"
          '';
        };

        programs.vscode = {
          enable = true;
          mutableExtensionsDir = false;
          package = pkgs.vscodium;
          extensions = with pkgs.vscode-extensions; [
            # UI
            #enkia.tokyo-night
            catppuccin.catppuccin-vsc
            vscode-icons-team.vscode-icons
            #iuyoy.highlight-string-code

            # Basic Language Support
            redhat.vscode-yaml

            # First Class Language Support
            ms-python.python
            ms-python.vscode-pylance

            # Nix
            bbenoist.nix
            jnoortheen.nix-ide

            # Remote Access
            ms-vscode-remote.remote-ssh

            # Data Science Related
            ms-toolsai.datawrangler
            ms-toolsai.jupyter
            #ms-toolsai.vscode-jupyter-powertoys
            ms-toolsai.jupyter-renderers

            # Code Formatting
            esbenp.prettier-vscode

            # Version Control
            eamodio.gitlens

            # AI Assist
            continue.continue
          ];

          userSettings = {

            "workbench.colorTheme" = lib.mkForce "Catppuccin Macchiato";
            "workbench.iconTheme" = "vscode-icons";
            "editor.formatOnSave" = true;
            "terminal.integrated.fontFamily" = "MesloLGS Nerd Font";
            "explorer.compactFolders" = false;
            "explorer.confirmDragAndDrop" = false;
            "explorer.confirmDelete" = false;

            # ---- Extension Settings ---- #
            "nix" = {
              "serverPath" = "nixd";
              "formatterPath" = "nixfmt";
            };

            "continue" = {
              "telemetryEnabled" = false;
            };
            "vsicons.dontShowNewVersionMessage" = true;
            "gitlens.telemetry.enabled" = false;
          };
        };

        home.stateVersion = "24.11"; # READ DOCS BEFORE CHANGING
      };
  };
}
