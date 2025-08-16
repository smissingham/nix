# ----- HOME CONFIGURATION
{
  config,
  lib,
  pkgs,
  mainUser,
  ...
}:
let
  autoDotsPath = "${config.environment.variables.NIX_CONFIG_HOME}/dots/auto";
  hostRebuildCli = (if pkgs.stdenv.isDarwin then "sudo darwin-rebuild" else "sudo nixos-rebuild");

  shellAliases = lib.mkMerge [
    mainUser.shellAliases
    {
      # GENERAL
      t = "${if pkgs.stdenv.isDarwin then "open -a" else ""} ${mainUser.terminalApp}";

      # TMUX
      tm = "tmux new-session -A -s";

      # NIX
      nxfmt = "find . -name '*.nix' -exec nixfmt {} \\;";
      nxr = "pushd $NIX_CONFIG_HOME; nxfmt; git add .; ${hostRebuildCli} switch --flake .#$(hostname) --impure --show-trace; popd";
      nxu = "pushd $NIX_CONFIG_HOME; find . -name \"flake.lock\" -delete; nix flake update; popd";
      nxgc = "nix-collect-garbage --delete-old";
    }
  ];

  mainUserHome = (if pkgs.stdenv.isDarwin then "/Users" else "/home") + "/${mainUser.username}";
in
{
  users.users.${mainUser.username} = {
    name = mainUser.username;
    home = mainUserHome;
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
      let
        # Get keys from mainUser.sops.secrets.terminal
        exportKeys = builtins.attrNames mainUser.sops.secrets.autoExport;

        terminalSecretExports = builtins.concatStringsSep "\n" (
          builtins.attrValues (
            builtins.mapAttrs (name: value: "export ${name}=\"$(cat ${value.path})\"") (
              lib.filterAttrs (name: value: builtins.elem name exportKeys) (config.sops.secrets or { })
            )
          )
        );
      in
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
          stateVersion = "25.05"; # READ DOCS BEFORE CHANGING
          username = mainUser.username;
          homeDirectory = mainUserHome;
          activation = {
            stowAutoDotfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
              ${pkgs.stow}/bin/stow -t "${config.xdg.configHome}" -d "${autoDotsPath}" -R .
              echo "Stowed automatically linked dots"
            '';
          };
          packages = with pkgs; [
          ];
          sessionVariables = lib.mkMerge [
            (lib.optionalAttrs (mainUser ? terminalApp) { TERMINAL = mainUser.terminalApp; })
            (lib.optionalAttrs (mainUser ? browserApp) { BROWSER = mainUser.browserApp; })
            (lib.optionalAttrs (mainUser ? editorApp) { EDITOR = mainUser.editorApp; })
          ];
        };

        programs.git = {
          enable = true;
          userName = mainUser.name;
          userEmail = mainUser.email;
          delta = {
            enable = true;
            options = {
              navigate = true;
              side-by-side = true;
              line-numbers = true;
              dark = true;
            };
          };
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
          initContent = ''
            ${terminalSecretExports}
            bindkey -r '^L'
            source ~/.p10k.zsh

            SHELL_FUNCS_DIR=${config.xdg.configHome}/shellfn
            if [ -d "$SHELL_FUNCS_DIR" ]; then
              for file in "$SHELL_FUNCS_DIR"/*.sh; do
                source "$file"
              done
            fi
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
