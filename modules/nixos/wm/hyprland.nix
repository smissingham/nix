{
  config,
  pkgs,
  lib,
  ...
}:
let
  moduleSet = "myNixOSModules";
  moduleCategory = "wm";
  moduleName = "hyprland";

  moduleDots = "${config.environment.variables.NIX_CONFIG_HOME}/modules/nixos/${moduleCategory}/dots/${moduleName}";

  optionPath = [
    moduleSet
    moduleCategory
    moduleName
  ];
  enablePath = optionPath ++ [ "enable" ];
in
{
  options = lib.setAttrByPath optionPath {
    enable = lib.mkEnableOption moduleName;
  };

  config = lib.mkIf (lib.getAttrFromPath enablePath config) {
    mySharedModules.home.stows = [
      "${moduleDots}"
      "${config.environment.variables.NIX_CONFIG_HOME}/modules/nixos/${moduleCategory}/dots/wofi"
    ];
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };

    environment.systemPackages = with pkgs; [
      kitty # backup / default terminal for hyprland
      hyprlock
      hyprpaper
      waybar
      wofi
      wl-clipboard
      clipman
      xfce.thunar
      pamixer
      pavucontrol
      playerctl
      catppuccin-cursors.mochaDark
    ];

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      XCURSOR_THEME = "catppuccin-mocha-dark-cursors";
      XCURSOR_SIZE = "32";
    };
  };
}
