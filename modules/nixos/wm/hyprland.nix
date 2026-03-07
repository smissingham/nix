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
      "${config.environment.variables.NIX_CONFIG_HOME}/modules/nixos/${moduleCategory}/dots/wofi"
    ];
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };

    programs.nm-applet.enable = true;

    environment.systemPackages = with pkgs; [
      kitty # backup / default terminal for hyprland
      kdePackages.dolphin # file explorer

      # Base UI Addons
      hyprlock
      hyprpaper
      waybar

      # Launcher & Clipboard
      wl-clipboard

      # System Utils
      bc
      blueberry
      pamixer
      pavucontrol
      playerctl

      # TUI's
      wiremix # audio
      bluetui # bluetooth
      yazi # file explorer

      # Screenshot tools
      grim # Screenshot utility for Wayland
      slurp # Select a region in Wayland
      swappy # Screenshot editor

      # launcher & application providers
      pkgsUnstable.elephant
      pkgsUnstable.walker
    ];

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      GTK_THEME = "adw-gtk3-dark";
    };

    # Enable dconf for gsettings to work properly
    programs.dconf.enable = true;

    home-manager.users.${mainUser.username} =
      {
        config,
        ...
      }:
      let
        wallpaperPath = config.stylix.image;
      in
      {
        # Stylix handles GTK theming automatically

        # Generate hyprpaper config with Stylix wallpaper
        xdg.configFile."hypr/hyprpaper.conf".text = ''
          preload = ${wallpaperPath}
          wallpaper = , ${wallpaperPath}
        '';
      };
  };
}
