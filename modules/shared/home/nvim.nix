{ mainUser, pkgs, ... }:
{

  environment.variables = {
    NVIM_CONF = "$NIX_CONFIG_HOME/modules/shared/home/dots/nvim";
  };
  #----- Applications in User Space -----#
  home-manager.users.${mainUser.username} = {

    home.packages = with pkgs; [
      neovim

      lazygit

      # required by lazy
      python313

      ripgrep
      gcc
      gnumake

      fd

      tree-sitter # for :TSInstallFromGrammar
      nodejs_20 # for :TSInstallFromGrammar

      dwt1-shell-color-scripts # snacks dashboard coloring

      # LSP Servers
      lua-language-server
      nixd
    ];

    home.file = {
      ".config/nvim" = {
        source = ./dots/nvim;
        recursive = true;
      };
    };
  };
}
