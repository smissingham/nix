# ----- HOME CONFIGURATION
{
  pkgs,
  pkgsUnstable,
  mainUser,
  ...
}:
let
  hostRebuildCli = (if pkgs.stdenv.isDarwin then "darwin-rebuild" else "sudo nixos-rebuild");

  shellAliases = {
    # GENERAL
    q = "exit";
    cl = "clear";
    ls = "eza";
    gg = "lazygit";
    ll = "eza -l";
    la = "eza -la";
    clip = "xclip -selection clipboard";

    # NEOVIM
    v = "nvim";
    vclear = "rm -rf ~/.local/share/nvim*";

    # TMUX
    tm = "tmux new-session -A -s";

    # NIX
    nxrepl = "nix repl --expr 'import <nixpkgs>{}'";
    nxfmt = "find . -name '*.nix' -exec nixfmt {} \\;";
    nxr = "pushd $NIX_CONFIG_HOME; nxfmt; git add .; ${hostRebuildCli} switch --flake .#$(hostname) --impure --show-trace; popd";
    nxgc = "nix-collect-garbage --delete-old";
    nxshell = "nix-shell -p";
    nxbuild = ''nix-build -E 'with import <nixpkgs> {}; callPackage '"$1"' {}' --show-trace'';

    # PROGRAMMING
    pyenv = "python3 -m venv .venv";

    fw = "aerospace list-windows --all | fzf --bind 'enter:execute(bash -c \"aerospace focus --window-id {1}\")+abort'";
  };
in
{

  users.users.${mainUser.username} = {
    name = mainUser.username;
    home = mainUser.homeDir;
  };

  home-manager = {
    # Allow unfree packages
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-bak";
    users.${mainUser.username} =
      {
        config,
        pkgs,
        lib,
        ...
      }:
      {
        xdg = {
          enable = true;
          userDirs = {
            extraConfig = {
              XDG_GAME_DIR = "${config.home.homeDirectory}/Documents/Games";
              XDG_GAME_SAVE_DIR = "${config.home.homeDirectory}/Documents/GameSaves";
            };
          };
        };

        home = {
          stateVersion = "24.11"; # READ DOCS BEFORE CHANGING
          username = mainUser.username;
          homeDirectory = mainUser.homeDir;
          activation = {
            stowDotfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
              DOTS_DIR="$HOME/Documents/Nix/dots"
              cd "$DOTS_DIR"

              # Stow each directory in dots to $HOME/.config
              for dir in */; do
                ${pkgs.stow}/bin/stow -t "$HOME/.config" -d "$DOTS_DIR" -R ''${dir%/}
                echo "Stowed ''${dir%/} to $HOME/.config"
              done
            '';
          };
        };

        programs.git = {
          enable = true;
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
      };
  };
}
