# ----- PACKAGES TO INSTALL ONLY ON NIXOS SYSTEMS -----#
{
  pkgs,
  pkgsUnstable,
  mainUser,
  ...
}:
let
  inherit (pkgs) mypkgs;
in
{
  #----- Applications in User Space -----#
  home-manager.users.${mainUser.username}.home.packages = with pkgs; [
    pkgsUnstable.ghostty
    mypkgs.filen-desktop

    # Work
    teams-for-linux

    # Office
    libreoffice

    # Dev Tools
    kdePackages.kate
    jetbrains-toolbox
  ];

  #----- Applications in System Space -----#
  environment.systemPackages = with pkgs; [
  ];
}
