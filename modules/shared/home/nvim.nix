{ mainUser, pkgs, ... }:
{

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

      # Language Servers & Formatters Required Often/Everywhere
      lua-language-server # Lua
      nixd # Nix
      taplo # TOML
      vscode-langservers-extracted # HTML, CSS, JSON, JS
      #nodePackages_latest.prettier
      prettierd

      # Shouldn't need project specific LSP's, put them in Nix flakes!
      #rust_analyzer
      #rustfmt
    ];

  };
}
