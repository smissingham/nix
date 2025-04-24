{ pkgs, lib, ... }:
let
  theme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  sourceUrl = "https://wallpaperswide.com/download/coral_reef_3-wallpaper-5120x2160.jpg";
  sourceSha = "sha256-avDEuBwd1+7AxlqUjeWTtTVT9DynmoN4iYxOVMgCUSE=";
  sourceImage = pkgs.fetchurl {
    url = sourceUrl;
    sha256 = sourceSha;
  };
in
{
  home-manager.sharedModules = [
    {
      stylix.targets = {
        #alacritty.enable = false;
        #kde.enable = false;
      };
    }
  ];

  stylix = {
    enable = true;
    autoEnable = false;
    polarity = "dark";
    base16Scheme = theme;
    image = sourceImage;

    fonts = {
      monospace = {
        name = "JetBrainsMono Nerd Font";
        package = pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
      };
      sansSerif = {
        name = "Ubuntu Nerd Font";
        package = pkgs.nerdfonts.override { fonts = [ "Ubuntu" ]; };
      };
      # serif = {
      #   name = "DejaVu Serif";
      #   package = pkgs.dejavu_fonts;
      # };
      emoji = {
        name = "Noto Color Emoji";
        package = pkgs.noto-fonts-emoji-blob-bin;
      };
      sizes = {
        terminal = 12;
        applications = 12;
        popups = 12;
        desktop = 12;
      };
    };
  };
}
