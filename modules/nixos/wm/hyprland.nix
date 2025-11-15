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
        pamixer
        pavucontrol
        playerctl

        # Screenshot tools
        grim # Screenshot utility for Wayland
        slurp # Select a region in Wayland
        swappy # Screenshot editor

        # Theming
        catppuccin-cursors.mochaDark
        catppuccin-gtk
        papirus-icon-theme
      ])
      ++ [
        # From flakes
        elephant
        walker
      ];

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      XCURSOR_THEME = "catppuccin-mocha-dark-cursors";
      XCURSOR_SIZE = "32";
      GTK_THEME = "Catppuccin-Mocha-Standard-Mauve-Dark";
    };

    home-manager.users.${mainUser.username} =
      {
        lib,
        config,
        ...
      }:
      {
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

        home.activation.linkElephantProviders = lib.hm.dag.entryAfter [ "stowDotfiles" ] ''
          $DRY_RUN_CMD rm -rf ${config.xdg.configHome}/elephant/providers
          $DRY_RUN_CMD ln -sf ${elephant}/lib/elephant/providers ${config.xdg.configHome}/elephant/providers
        '';
      };
  };
}
