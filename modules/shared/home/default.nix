# ----- HOME CONFIGURATION T
{
  config,
  lib,
  pkgs,
  mainUser,
  pkgsUnstable,
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
    # GENERAL
    q = "exit";
    ls = "eza";
    cl = "clear";
    ll = "eza -l";
    la = "eza -la";
    clip = "xclip -selection clipboard";

    # NEOVIM
    v = "nvim";
    vl = "NVIM_APPNAME=nvim-live nvim --clean --cmd \"set runtimepath+=$NIX_CONFIG_HOME/modules/shared/home/dots/nvim/\" -c \"source $NIX_CONFIG_HOME/modules/shared/home/dots/nvim/init.lua\"";
    vclear = "rm -rf ~/.local/share/nvim*";

    # TMUX
    tm = "tmux new-session -A -s";

    # NIX
    nxrepl = "nix repl --expr 'import <nixpkgs>{}'";
    nxfmt = "find . -name '*.nix' -exec nixfmt {} \\;";
    nxrbs = "pushd $NIX_CONFIG_HOME; nxfmt; git add .; ${hostRebuildCli} switch --flake .#$(hostname) --show-trace; popd";
    nxgc = "nix-collect-garbage --delete-old";
    nxshell = "nix-shell -p";
    nxbuild = ''nix-build -E 'with import <nixpkgs> {}; callPackage '"$1"' {}' --show-trace'';

    # PROGRAMMING
    pyenv = "python3 -m venv .venv";
  };
in
{
  imports = [
    ./firefox.nix
    ./vscode.nix
    ./nvim.nix
  ];

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
          stateVersion = "24.11"; # READ DOCS BEFORE CHANGING
          username = mainUser.username;
          homeDirectory = (if pkgs.stdenv.isDarwin then "/Users/" else "/home/") + mainUser.username;
          file = {
            ".config/nixpkgs" = {
              source = ./dots/nixpkgs;
              recursive = true;
            };
          };
        };

        xdg = {
          enable = true;
          userDirs = {
            extraConfig = {
              XDG_GAME_DIR = "${config.home.homeDirectory}/Documents/Games";
              XDG_GAME_SAVE_DIR = "${config.home.homeDirectory}/Documents/GameSaves";
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

        programs.zoxide = {
          enable = true;
          enableZshIntegration = true;
        };

        programs.zsh = {
          enable = true;
          enableCompletion = true;
          shellAliases = shellAliases;
          #autosuggestion.enable = true;
          syntaxHighlighting.enable = true;
          initExtra = ''
            source ~/.p10k.zsh
            source ~/.secrets/api-keys.env
          '';

          history = {
            size = 10000;
          };

          plugins = [
            {
              name = "powerlevel10k";
              src = pkgs.zsh-powerlevel10k;
              file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
            }
            {
              name = "zsh-autosuggestions";
              src = pkgs.fetchFromGitHub {
                owner = "zsh-users";
                repo = "zsh-autosuggestions";
                rev = "v0.4.0";
                sha256 = "0z6i9wjjklb4lvr7zjhbphibsyx51psv50gm07mbb0kj9058j6kc";
              };
            }
          ];
        };

        # note after rebuild, to force tmux conf switch: `tmux source ~/.config/tmux/tmux.conf`
        programs.tmux = {
          enable = true;
          shell = "${pkgs.zsh}/bin/zsh";
          plugins = with pkgs; [
            pkgsUnstable.tmuxPlugins.catppuccin
            tmuxPlugins.cpu
            tmuxPlugins.battery
            tmuxPlugins.better-mouse-mode
            tmuxPlugins.sensible
            tmuxPlugins.vim-tmux-navigator
          ];
          extraConfig = builtins.readFile ./dots/tmux/tmux.conf;
        };

        programs.alacritty = {
          enable = true;
          settings = {
            general.import = [ "${alacrittyColors}/catppuccin-mocha.toml" ];
            font = {
              #size = 12; # 14 creates glitches on p10k prompt
              normal.family = lib.mkForce "JetBrainsMono Nerd Font"; # "MesloLGS Nerd Font"; # p10k recommends
            };
            env = {
              TERM = "xterm-256color";
            };
            window = {
              opacity = lib.mkForce 0.975;
              padding.x = 12;
              padding.y = 12;
            };
            keyboard.bindings =
              [

              ]
              ++ (
                if pkgs.stdenv.isDarwin then
                  [

                    # Terminal controls (match Linux behavior)
                    {
                      key = "S";
                      mods = "Command";
                      chars = "\\u0013";
                    }

                    {
                      key = "Slash";
                      mods = "Command";
                      chars = "\\u001f";
                    }

                    {
                      key = "Z";
                      mods = "Command";
                      chars = "\\u001a";
                    }

                    {
                      key = "Space";
                      mods = "Command";
                      chars = "\\u0000";
                    }
                  ]
                else
                  [ ]
              );
          };
        };

        #        programs.wezterm = {
        #          enable = true;
        #          enableBashIntegration = true;
        #          enableZshIntegration = true;
        #          # colorSchemes = {
        #          #   catpuccin-mocha = "${alacrittyColors}/catppuccin-mocha.toml";
        #          # };
        #          extraConfig = ''
        #            return {
        #              font = wezterm.font("JetBrains Mono"),
        #              color_scheme = "Catppuccin Mocha"
        #            }
        #          '';
        #
        #        };

      };
  };
}
