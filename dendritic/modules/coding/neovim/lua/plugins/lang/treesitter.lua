return {
  { "virchau13/tree-sitter-astro" },
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter");
      ts.setup({
        highlight = { enable = true },
        indent = { enable = true },
      });
      ts.install {
          -- Vim Related
          "lua",
          "vim",
          "vimdoc",
          "query",
    
          -- Text / Publishing
          "latex",
          "markdown",

          -- Shell / Sysops
          "nix",
          "nu",
          "bash",
          "toml",
          "yaml",

          -- Programming
          "python",
          "sql",
          "rust",

          -- Web
          "css",
          "html",
          "json",
          "astro",
          "javascript",
          "typescript",
          "tsx",
          "svelte",
          "vue",
      }
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    init = function()
      vim.g.no_plugin_maps = true
    end
  },
}
