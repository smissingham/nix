{
  lib,
  pkgs,
  config,
  mainUser,
  ...
}:
let
  sysConfig = config;

  moduleSet = "mySharedModules";
  moduleCategory = "workflow";
  moduleName = "shell";

  optionPath = [
    moduleSet
    moduleCategory
    moduleName
  ];

  stowPathsOptionAttr = lib.getAttrFromPath (optionPath ++ [ "stowPaths" ]) config;
  sourcePathsOptionAttr = lib.getAttrFromPath (optionPath ++ [ "sourcePaths" ]) config;
  aliasesOptionAttr = lib.getAttrFromPath (optionPath ++ [ "aliases" ]) config;
  initExtrasOptionAttr = lib.getAttrFromPath (optionPath ++ [ "initExtras" ]) config;

  hostRebuildCli = (if pkgs.stdenv.isDarwin then "sudo darwin-rebuild" else "sudo nixos-rebuild");

  shellAliases = lib.mkMerge [
    mainUser.shellAliases
    aliasesOptionAttr
    {
      # GENERAL
      t = "${if pkgs.stdenv.isDarwin then "open -a" else ""} ${mainUser.terminalApp}";

      # TMUX
      tm = "tmux new-session -A -s";
    }
  ];
in
{
  options = lib.setAttrByPath optionPath {
    stowPaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "List of paths to stow into XDG_CONFIG_HOME";
      default = [ ];
    };
    sourcePaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "List of paths containing .sh files to source into shells";
      default = [ ];
    };
    aliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      description = "Shell aliases to add to shells";
      default = { };
    };
    initExtras = lib.mkOption {
      type = lib.types.lines;
      description = "Additional shell initialization code to add to shells";
      default = "";
    };
  };

  config = lib.mkMerge [
    {
      #----- Packages in User Space -----#
      home-manager.users.${mainUser.username} =
        {
          lib,
          config,
          ...
        }:
        let
          usrConfigHome = config.xdg.configHome;
          nixConfigHome = sysConfig.environment.variables.NIX_CONFIG_HOME;

          nxfmtBin = pkgs.writeShellScriptBin "nxfmt" ''
            find . -name '*.nix' -exec nixfmt {} \;
          '';

          nxrBin = pkgs.writeShellScriptBin "nxr" ''
            set -e
            pushd ${nixConfigHome} > /dev/null || exit 1
              # Format all nix files
              nxfmt

              # Backup git index
              cp .git/index .git/index.backup
             
              # Stage all files for nix to see them
              git add . > /dev/null 2>&1

              # Run the nix rebuild
              ${hostRebuildCli} switch --flake .#$(hostname) --impure --show-trace
              
              # Restore original git index
              mv .git/index.backup .git/index
            popd > /dev/null
          '';

          nxuBin = pkgs.writeShellScriptBin "nxu" ''
            set -e
            pushd ${nixConfigHome} > /dev/null || exit 1
              find . -name "flake.lock" -delete
              nix flake update
            popd > /dev/null
          '';

          nxgcBin = pkgs.writeShellScriptBin "nxgc" ''
            nix-collect-garbage --delete-old
          '';

          shReloadBin = pkgs.writeShellScriptBin "sh_reload" ''
            if command -v tmux &> /dev/null && [ -f "${usrConfigHome}/tmux/tmux.conf" ]; then
              tmux source "${usrConfigHome}/tmux/tmux.conf" 2>/dev/null || true
              echo "Reloaded: tmux configuration"
            fi
          '';

          defaultStowPath = "${nixConfigHome}/dots/auto";
          shStowBin = pkgs.writeShellScriptBin "sh_stow" ''
            for path in ${lib.escapeShellArgs (stowPathsOptionAttr ++ [ defaultStowPath ])}; do
              if [ -d "$path" ]; then
                ${pkgs.stow}/bin/stow -t "${usrConfigHome}" -d "$path" -R .
                echo "Stowed: $path"
              else
                echo "Skipped (not a directory): $path" >&2
              fi
            done
          '';

          defaultSourcePath = "${usrConfigHome}/shell";
          shSourceBin = pkgs.writeShellScriptBin "sh_source" ''
            for path in ${lib.escapeShellArgs (sourcePathsOptionAttr ++ [ defaultSourcePath ])}; do
              if [ -d "$path" ]; then
                while IFS= read -r file; do
                  if [ -r "$file" ]; then
                    source "$file"
                  else
                    echo "Skipped (not readable): $file" >&2
                  fi
                done < <(${pkgs.fd}/bin/fd --type file --extension sh . "$path")
              else
                echo "Skipped (not a directory): $path" >&2
              fi
            done
          '';

          shellInitScript = ''
            ${shSourceBin}/bin/sh_source
            ${initExtrasOptionAttr}
          '';

          # Convert shell aliases to executable binaries for non-interactive shell usage
          aliasBins = lib.mapAttrsToList (
            name: command:
            pkgs.writeShellScriptBin name ''
              exec ${command} "$@"
            ''
          ) aliasesOptionAttr;

        in
        {
          home = {
            sessionVariables = {
              TERMINAL = lib.mkDefault mainUser.terminalApp;
              BROWSER = lib.mkDefault mainUser.browserApp;
              EDITOR = lib.mkDefault mainUser.editorApp;
            };
            activation = {
              nixHomeSetupActivate = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                ${shStowBin}/bin/sh_stow
                ${shellInitScript}
              '';
            };
            packages = [
              shStowBin
              shSourceBin
              shReloadBin
              nxfmtBin
              nxrBin
              nxuBin
              nxgcBin
            ]
            ++ aliasBins;
          };

          programs.bash = {
            enable = true;
            shellAliases = shellAliases;
            enableCompletion = true;
            initExtra = shellInitScript;
          };

          programs.zsh = {
            enable = true;
            shellAliases = shellAliases;
            enableCompletion = true;
            syntaxHighlighting.enable = true;
            initContent = ''
              ${shellInitScript}
              bindkey -r '^L'
              source ~/.p10k.zsh
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

          programs.direnv = {
            enable = true;
            enableZshIntegration = true;
            enableBashIntegration = true;
            nix-direnv.enable = true;
          };

          programs.zoxide = {
            enable = true;
            enableZshIntegration = true;
            enableBashIntegration = true;
          };

        };

      #----- Packages in System Space -----#
      environment.systemPackages = with pkgs; [
        # System CLI Utils
        pciutils
        usbutils
        findutils

        # Dev Utils
        dig
        gnupg
        git
        just
        stow

        # CLI Usability
        tmux
        bat
        btop
        fd
        eza
        fzf
        tldr
        xclip
      ];
    }

  ];
}
