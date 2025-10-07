{
  config,
  lib,
  pkgs,
  mainUser,
  ...
}:

let
  moduleSet = "mySharedModules";
  moduleCategory = "browsers";
  moduleName = "floorp";

  cfg = config.${moduleSet}.${moduleCategory}.${moduleName};
in
{
  options.${moduleSet}.${moduleCategory}.${moduleName} = with lib; {
    enable = mkEnableOption moduleName;
  };

  config = lib.mkIf cfg.enable {

    home-manager.users.${mainUser.username} = {

      programs.floorp = {
        enable = true;
        # TODO: Unpin this once floorp builds properly again in stable
        package =
          (import
            (builtins.fetchTarball {
              url = "https://github.com/NixOS/nixpkgs/archive/c2ae88e026f9525daf89587f3cbee584b92b6134.tar.gz";
              sha256 = "sha256-erbiH2agUTD0Z30xcVSFcDHzkRvkRXOQ3lb887bcVrs=";
            })
            {
              inherit (pkgs) system;
              config.allowUnfree = true;
            }
          ).floorp;
      }
      // config.${moduleSet}.${moduleCategory}.firefoxConfig;
    };
  };
}
