{
  pkgs,
  mainUser,
  ...
}:
let
  mainUserHome = (if pkgs.stdenv.isDarwin then "/Users" else "/home") + "/${mainUser.username}";
in
{
  config = {
    users.users.${mainUser.username} = {
      name = mainUser.username;
      home = mainUserHome;
      shell = pkgs.zsh;
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
        lib.mkMerge [
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
          }
        ];
    };
  };
}
