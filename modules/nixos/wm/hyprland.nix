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

  moduleDots = "${config.environment.variables.NIX_CONFIG_HOME}/modules/nixos/${moduleCategory}/dots/${moduleName}";

  # Fetch elephant and walker from flakes
  elephantFlake = builtins.getFlake "github:abenz1267/elephant";
  elephant = elephantFlake.packages.${pkgs.system}.default;

  walkerFlake = builtins.getFlake "github:abenz1267/walker";
  walker = walkerFlake.packages.${pkgs.system}.default;

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
    programs.thunar.enable = true;

    environment.systemPackages =
      (with pkgs; [
        kitty # backup / default terminal for hyprland

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

        # Screenshot tools
        grim # Screenshot utility for Wayland
        slurp # Select a region in Wayland
        swappy # Screenshot editor
      ])
      ++ [
        # From flakes
        elephant
        walker
      ];

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      GTK_THEME = "adw-gtk3-dark";
    };

    # Enable dconf for gsettings to work properly
    programs.dconf.enable = true;

    home-manager.users.${mainUser.username} =
      {
        lib,
        config,
        ...
      }:
      let
        wallpaperPath = config.stylix.image;
      in
      {
        # Stylix handles GTK theming automatically

        # But we need to configure xfconf for Thunar/XFCE apps
        xfconf.settings = {
          xsettings = {
            "Net/ThemeName" = "adw-gtk3-dark";
            "Net/IconThemeName" = "Papirus-Dark";
            "Gtk/CursorThemeName" = "catppuccin-mocha-dark-cursors";
            "Gtk/CursorThemeSize" = 32;
            "Net/EnableEventSounds" = false;
            "Net/EnableInputFeedbackSounds" = false;
          };
        };

        # Generate hyprpaper config with Stylix wallpaper
        xdg.configFile."hypr/hyprpaper.conf".text = ''
          preload = ${wallpaperPath}
          wallpaper = , ${wallpaperPath}
        '';

        home.activation.linkElephantProviders = lib.hm.dag.entryAfter [ "stowDotfiles" ] ''
          $DRY_RUN_CMD rm -rf ${config.xdg.configHome}/elephant/providers
          $DRY_RUN_CMD ln -sf ${elephant}/lib/elephant/providers ${config.xdg.configHome}/elephant/providers
        '';
      };
  };
}
