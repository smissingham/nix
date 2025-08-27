{
  config,
  lib,
  pkgs,
  ...
}:

let
  moduleSet = "myNixOSModules";
  moduleCategory = "entertainment";
  moduleName = "gaming";

  cfg = config.${moduleSet}.${moduleCategory}.${moduleName};
in
{
  options.${moduleSet}.${moduleCategory}.${moduleName} = with lib; {
    enable = mkEnableOption moduleName;
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      lutris
      protonup-ng
      #xboxdrv #-- Replaced by in-tree kernel driver, removed from nixos at 25.05
      gamescope
    ];
    programs = {
      steam = {
        enable = true;
        remotePlay.openFirewall = true;
      };
      gamemode.enable = true;
      corectrl = {
        enable = true;
      };
    };
  };
}
