# ----- PACKAGES TO INSTALL ONLY ON NIXOS SYSTEMS -----#
{
  pkgs,
  mainUser,
  ...
}:
{
  #----- Applications in User Space -----#
  home-manager.users.${mainUser.username}.home.packages = with pkgs; [
  ];
  #----- Applications in System Space -----#
  environment.systemPackages = with pkgs; [
  ];
}
