# ----- HOME CONFIGURATION ONLY ON NIXOS SYSTEMS -----#
{
  pkgs,
  mainUser,
  ...
}:
{
  home-manager.users.${mainUser.username} = {
  };
}
