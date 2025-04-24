{ pkgs, ... }:
{
  plugins = {
    treesitter = {
      enable = true;
      #folding = true;
      settings = {
        highlight = {
          enable = true;
        };
        indent = {
          enable = true;
        };

        incremental_selection = {
          enable = true;
          keymaps = {
            init_selection = "<C-space>";
            node_incremental = "<C-space>";
            scope_incremental = false;
            node_decremental = "<bs>";
          };
        };

        auto_install = true;
        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          bash
          json
          lua
          make
          markdown
          nix
          regex
          toml
          vim
          vimdoc
          xml
          yaml
        ];
      };
    };

    treesitter-context.enable = true;

    treesitter-textobjects = {
      enable = true;

      move = {
        enable = true;
        gotoNextStart.__raw = ''
          {
            ["](b"] = "@block.outer",
            ["](f"] = "@function.outer",
          }'';
        gotoNextEnd.__raw = ''
          {
            ["])b"] = "@block.outer",
            ["])f"] = "@function.outer",
          }'';
        gotoPreviousStart.__raw = ''
          {
            ["[(b"] = "@block.outer",
            ["[(f"] = "@function.outer",
          }'';
        gotoPreviousEnd.__raw = ''
          {
            ["[)b"] = "@block.outer",
            ["[)f"] = "@function.outer",
          }'';
      };
    };
  };
}
