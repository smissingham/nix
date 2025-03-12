# ----- PACKAGES TO INSTALL ON ALL (DARWIN + NIXOS) SYSTEMS -----#
{ pkgs, mainUser, ... }:
{
  #----- Applications in User Space -----#
  home-manager.users.${mainUser.username}.home.packages = with pkgs; [
    raycast
    stats
  ];
  #----- Applications in System Space -----#
  environment.systemPackages = with pkgs; [

  ];
}

# ----- NOTING MANUALLY INSTALLED PACKAGES, NOT SUPPORTED BY NIX -----#
# AltTab
# Moom
# Cursor
