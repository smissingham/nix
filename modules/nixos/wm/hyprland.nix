{
  config,
  pkgs,
  pkgsUnstable,
  lib,
  mainUser,
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
    ];

    # hardware.graphics = {
    #   enable = true;
    #   enable32Bit = true;
    #   extraPackages = [
    #     pkgs.mesa.drivers
    #   ];
    # };

    # hardware.opengl = {
    #   enable = true;
    #   #driSupport = true;
    #   #driSupport32Bit = true;
    # };

    programs.hyprland = {
      enable = true;
      package = pkgsUnstable.hyprland;
      withUWSM = true;
    };

    environment.systemPackages = with pkgs; [
      kitty # default hypr terminal, just in case
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
