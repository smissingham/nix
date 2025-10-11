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
  moduleName = "shellenv";

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

  config = {
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
          find . -name '*.nix' -exec ${pkgs.deadnix}/bin/deadnix -e -f {} \;
          find . -name '*.nix' -exec ${pkgs.nixfmt-rfc-style}/bin/nixfmt {} \;
        '';

        nxrBin = pkgs.writeShellScriptBin "nxr" ''
          set -e
          pushd ${nixConfigHome} > /dev/null || exit 1
            nxfmt

            cp .git/index .git/index.backup
           
            git add . > /dev/null 2>&1

            ${hostRebuildCli} switch --flake .#$(hostname) --impure --show-trace
            
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
          nix-store --optimise
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
        shSourceScript = pkgs.writeText "sh_source.sh" ''
          for file in $(${pkgs.fd}/bin/fd --type file --extension sh . ${
            lib.escapeShellArgs (sourcePathsOptionAttr ++ [ defaultSourcePath ])
          }); do 
            echo "Sourced: $file"
            . "$file"
          done
        '';
        shellAliases = lib.mkMerge [
          mainUser.shellAliases
          aliasesOptionAttr
          {
            tm = "tmux new-session -A -s";
            nxs = "nix-search-tv";
            nxsh = "nix-shell -I nixpkgs=channel:nixos-unstable -p";
          }
        ];

        shellInitScript = ''
          ${initExtrasOptionAttr}
          . ${shSourceScript}
          clear
        '';

        aliasBins = lib.mapAttrsToList (
          name: command:
          pkgs.writeShellScriptBin name ''
            exec ${command} "$@"
          ''
        ) aliasesOptionAttr;
      in
      {
        home = {
          packages = [
            shStowBin
            shReloadBin
            nxfmtBin
            nxrBin
            nxuBin
            nxgcBin
          ]
          ++ aliasBins;

          activation = {
            nixHomeSetupActivate = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
              ${initExtrasOptionAttr}
              . ${shSourceScript}
              ${shStowBin}/bin/sh_stow
            '';
          };
        };

        _module.args.shellHelpers = {
          inherit
            shellAliases
            shellInitScript
            ;
        };
      };
  };
}
