{ mainUser, pkgs, ... }:
{

  #----- Applications in User Space -----#
  home-manager.users.${mainUser.username} = {
    home.packages = with pkgs; [
      neovim

      # required by lazy
      python313

      ripgrep # required by telescope
      gcc # required by telescope-fzf-native
      gnumake # required by telescope-fzf-native
    ];

    # home.file = {
    #   ".config/nvim" = {
    #     source = ./dots/nvim;
    #     recursive = true;
    #   };
    # };
  };
}
