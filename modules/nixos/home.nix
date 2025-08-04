# ----- HOME CONFIGURATION ONLY ON NIXOS SYSTEMS -----#
{
  pkgs,
  mainUser,
  ...
}:
{
  home-manager.users.${mainUser.username} = {
    gtk = {
      enable = true;
      theme = {
        name = "Adwaita-dark";
        package = pkgs.adwaita-icon-theme;
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
    };
  };
}
