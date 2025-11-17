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
      protonup-ng
      gamescope
    ];
    programs = {
      steam = {
        enable = true;
        remotePlay.openFirewall = true;
        extest.enable = true;
        #gamescopeSession.enable = true;
        extraCompatPackages = with pkgs; [ proton-ge-bin ];
      };
      gamemode.enable = true;
    };

    environment.sessionVariables = {
      #STEAM_FORCE_DESKTOPUI_SCALING = "1.33";
    };
  };
}
