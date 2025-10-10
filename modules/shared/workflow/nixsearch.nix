{
  pkgs,
  mainUser,
  ...
}:
{
  home-manager.users.${mainUser.username} = {
    home.packages = [
      pkgs.nix-search-tv
    ];
  };
}
