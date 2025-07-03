{
  mainUser,
  pkgs,
  ...
}:
let
  inherit (pkgs) mypkgs;
in
{

  #----- Applications in User Space -----#
  home-manager.users.${mainUser.username} = {

    home.packages = with pkgs; [
      # ----- Core Packages Required -----#
      neovim

      # ----- Developer Tools -----#
      lazygit
      #mypkgs.mcp-hub
      mypkgs.claude-code

      # ----- CLI Utilities -----#
      fd
      ripgrep
      gcc
      gnumake

      # ----- Required Runtimes -----#
      python312
      nodejs_20 # for :TSInstallFromGrammar
      uv

      # ----- Language Servers -----#
      lua-language-server # Lua
      nixd # Nix
      taplo # TOML
      vscode-langservers-extracted # HTML, CSS, JSON, JS
      prettierd

      #----- Required by Plugins -----#
      tree-sitter # for :TSInstallFromGrammar
      dwt1-shell-color-scripts # snacks dashboard coloring
    ];
  };
}
