# ----- General Home Configuation ----- #
{
  pkgs,
  mainUser,
  ...
}:
let
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
        ...
      }:
      let
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
        };
      };
  };
}
