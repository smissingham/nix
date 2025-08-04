{
  config,
  pkgs,
  lib,
  mainUser,
  ...
}:
let
  moduleSet = "myNixOSModules";
  moduleCategory = "wm";
  moduleName = "hyprland";

  cfg = config.${moduleSet}.${moduleCategory}.${moduleName};
in
{

  options.${moduleSet}.${moduleCategory}.${moduleName} = with lib; {
    enable = mkEnableOption moduleName;
  };

  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };

    environment.systemPackages = with pkgs; [
      hyprlock
      hyprpaper
      waybar
      wofi
      wl-clipboard
      clipman
      xfce.thunar
    ];

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    home-manager.users.${mainUser.username} = {
      # home.file = {
      #   ".config/hypr" = {
      #     source = mainUser.dotsPath + /hypr;
      #     recursive = true;
      #   };
      # };
    };
  };
}
