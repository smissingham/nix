{
  lib,
  pkgs,
  mainUser,
  dendritic,
  ...
}:
{
  config = lib.mkMerge [
    (lib.mkIf pkgs.stdenv.isDarwin {
      system.activationScripts.extraActivation.text = lib.mkAfter ''
        /usr/bin/dscl . -create /Users/${mainUser.username} UserShell ${dendritic.sm-shell}/bin/sm-shell
      '';
    })
    {
      environment.shells = [ "${dendritic.sm-shell}/bin/sm-shell" ];
      users.users.${mainUser.username} = {
        shell = "${dendritic.sm-shell}/bin/sm-shell";
      };

      home-manager.users.${mainUser.username} =
        {
          lib,
          ...
        }:
        {
          home.packages = lib.optionals pkgs.stdenv.isLinux [ pkgs.xclip ];

          programs.git = {
            # enable = true;
            settings.user = {
              name = mainUser.name;
              email = mainUser.email;
            };
          };
        };
    }
  ];
}
