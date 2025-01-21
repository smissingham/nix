{
  config,
  pkgs,
  lib,
  mainUser,
  ...
}:
let
  moduleSet = "mySystemModules";
  moduleCategory = "wm";
  moduleName = "gnome-xserver";

  cfg = config.${moduleSet}.${moduleCategory}.${moduleName};
in
{

  options.${moduleSet}.${moduleCategory}.${moduleName} = with lib; {
    enable = mkEnableOption moduleName;
  };

  config = lib.mkIf cfg.enable {

    services.xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

  };
}
