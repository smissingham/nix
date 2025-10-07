{
  pkgs,
  mainUser,
  config,
  lib,
  ...
}:
let
  sysConfig = config;
  mainUserHome = (if pkgs.stdenv.isDarwin then "/Users" else "/home") + "/${mainUser.username}";

  optionPath = [
    "mySharedModules"
    "home"
  ];

  stowsOptionAttr = lib.getAttrFromPath (optionPath ++ [ "stows" ]) config;
in
{
  options = lib.setAttrByPath optionPath {
    stows = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "List of paths to stow into XDG_CONFIG_HOME";
      default = [ ];
    };
  };

  config = {
    users.users.${mainUser.username} = {
      name = mainUser.username;
      home = mainUserHome;
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-bak";
      users.${mainUser.username} =
        {
          lib,
          config,
          ...
        }:
        {
          home = {
            stateVersion = "25.05";
            username = mainUser.username;
            homeDirectory = mainUserHome;
            sessionVariables = {
              TERMINAL = lib.mkDefault mainUser.terminal;
              BROWSER = lib.mkDefault mainUser.browser;
              EDITOR = lib.mkDefault mainUser.editor;
            };

            # TODO: Move dots to profile
            activation = {
              stowDotfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                for path in ${
                  lib.escapeShellArgs (
                    stowsOptionAttr ++ [ "${sysConfig.environment.variables.NIX_CONFIG_HOME}/dots/auto" ]
                  )
                }; do
                  if [ -d "$path" ]; then
                    ${pkgs.stow}/bin/stow -t "${config.xdg.configHome}" -d "$path" -R .
                    echo "Stowed: $path"
                  else
                    echo "Skipped (not a directory): $path" >&2
                  fi
                done
              '';
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
            configFile."nixpkgs/config.nix".text = ''
              {
                allowUnfree = true;
                allowUnfreePredicate = _: true;
              }
            '';
            configFile."nix/nix.conf".text = ''
              experimental-features = nix-command flakes
            '';
          };
        };
    };
  };
}
