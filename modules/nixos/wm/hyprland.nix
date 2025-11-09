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

    environment.systemPackages = with pkgs; [
      kitty # backup / default terminal for hyprland
      hyprlock
      hyprpaper
      waybar
      wofi
      wl-clipboard
      clipman
      pamixer
      pavucontrol
      playerctl
      catppuccin-cursors.mochaDark
      catppuccin-gtk
      papirus-icon-theme
    ];

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      XCURSOR_THEME = "catppuccin-mocha-dark-cursors";
      XCURSOR_SIZE = "32";
      GTK_THEME = "Catppuccin-Mocha-Standard-Mauve-Dark";
    };

    home-manager.users.${mainUser.username} = {
      gtk = {
        enable = true;
        theme = {
          name = "Catppuccin-Mocha-Standard-Mauve-Dark";
          package = pkgs.catppuccin-gtk.override {
            accents = [ "mauve" ];
            size = "standard";
            variant = "mocha";
          };
        };
        iconTheme = {
          name = "Papirus-Dark";
          package = pkgs.papirus-icon-theme;
        };
        cursorTheme = {
          name = "catppuccin-mocha-dark-cursors";
          package = pkgs.catppuccin-cursors.mochaDark;
          size = 32;
        };
        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = true;
        };
        gtk4.extraConfig = {
          gtk-application-prefer-dark-theme = true;
        };
      };
    };
  };
}
