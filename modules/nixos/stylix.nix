{
  config,
  pkgs,
  lib,
  ...
}:
let
  moduleSet = "myNixOSModules";
  moduleName = "stylix";

  optionPath = [
    moduleSet
    moduleName
  ];
  enablePath = optionPath ++ [ "enable" ];
in
{
  options = lib.setAttrByPath optionPath {
    enable = lib.mkEnableOption moduleName;
  };

  config = lib.mkIf (lib.getAttrFromPath enablePath config) {
    stylix = {
      enable = true;

      # Use Catppuccin Mocha as base16 scheme
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

      # Set a wallpaper - dark tropical island evening
      image = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/zhichaoh/catppuccin-wallpapers/main/landscapes/tropic_island_night.jpg";
        sha256 = "0p296jiyc59ax99b2n2430c2j8h5ja1fxjzhf3m42v623v938vqn";
      };

      cursor = {
        package = pkgs.catppuccin-cursors.mochaDark;
        name = "catppuccin-mocha-dark-cursors";
        size = 32;
      };

      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font Mono";
        };
        sansSerif = {
          package = pkgs.noto-fonts;
          name = "Noto Sans";
        };
        serif = {
          package = pkgs.noto-fonts;
          name = "Noto Serif";
        };
        sizes = {
          applications = 11;
          terminal = 18;
          desktop = 11;
          popups = 11;
        };
      };

      opacity = {
        applications = 1.0;
        terminal = 0.95;
        desktop = 1.0;
        popups = 1.0;
      };

      polarity = "dark";

      targets = {
        gtk.enable = true;
        gnome.enable = false;
        console.enable = true;
      };
    };

    # Install adw-gtk3 theme that stylix uses and catppuccin folder icons
    environment.systemPackages = with pkgs; [
      adw-gtk3
      catppuccin-papirus-folders
    ];
  };
}
