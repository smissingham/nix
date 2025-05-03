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
      python312

      ripgrep
      gcc
      gnumake

      fd

      tree-sitter # for :TSInstallFromGrammar
      nodejs_20 # for :TSInstallFromGrammar

      dwt1-shell-color-scripts # snacks dashboard coloring

      # Language Servers & Formatters
      lua-language-server
      nixd

      # Shouldn't need project specific LSP's, put them in Nix flakes!
      #taplo
      #rust_analyzer
      #rustfmt
    ];

    home.file = {
      ".config/nvim" = {
        source = ./dots/nvim;
        recursive = true;
      };
    };
  };
}
