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
    webGuiPort = mkOption {
      type = types.int;
      default = 8384;
    };
  };

  config = lib.mkMerge [
    # Cross Platform Home Manager Config
    (lib.mkIf cfg.enable {
      home-manager.users.${mainUser.username} = {
        services.syncthing = {
          enable = true;
          #guiAddress = "127.0.0.1:${builtins.toString cfg.webGuiPort}";
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
    })
  ];

}
