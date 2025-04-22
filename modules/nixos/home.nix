# ----- HOME CONFIGURATION ONLY ON NIXOS SYSTEMS -----#
{
  pkgs,
  mainUser,
  ...
}:
{
  home-manager.users.${mainUser.username}.home = {
    packages = with pkgs; [
      #floorp
      firefox
      filen-desktop

      # Work
      teams-for-linux

      # Office
      libreoffice
      #thunderbird
      filen-desktop

      # Dev Tools
      kdePackages.kate
      #jetbrains-toolbox
    ];
  };
}
