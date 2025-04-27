{
  config,
  lib,
  pkgs,
  mainUser,
  ...
}:
let
  moduleSet = "myHomeModules";
  moduleCategory = "productivity";
  moduleName = "syncthing";

  cfg = config.${moduleSet}.${moduleCategory}.${moduleName};
in
{

  options.${moduleSet}.${moduleCategory}.${moduleName} = with lib; {
    enable = mkEnableOption moduleName;
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${mainUser.username} = {
      services.syncthing = {
        enable = true;
        #settings = { };
        # settings = {
        #   devices.coeus = {
        #     autoAcceptFolders = true;
        #   };
        #   devices.plutus = {
        #     autoAcceptFolders = true;
        #   };
        # };
      };
    };
  };
}
