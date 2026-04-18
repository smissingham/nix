return {
  { "virchau13/tree-sitter-astro" },
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "query" },
        callback = function()
          vim.diagnostic.disable(0)
        end,
      })
    end,
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = {
          "lua",
          "vim",
          "vimdoc",
          "query",
          "svelte",
          "astro",
          "typescript",
          "javascript",
          "markdown",
          "markdown_inline",
          "css",
          "html",
          "json",
          "nix",
          "python",
          "sql",
          "rust",
          "bash",
          "toml",
          "yaml",
        },
        sync_install = false,
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = {
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
            ["ab"] = "@block.outer",
            ["ib"] = "@block.inner",
            ["al"] = "@loop.outer",
            ["il"] = "@loop.inner",
            ["ai"] = "@conditional.outer",
            ["ii"] = "@conditional.inner",
            ["as"] = "@statement.outer",
            ["is"] = "@statement.inner",
            ["am"] = "@comment.outer",
            ["im"] = "@comment.inner",
          },
        },
        move = {
          set_jumps = true,
          goto_next_start = {
            ["]f"] = "@function.outer",
            ["]c"] = "@class.outer",
            ["]a"] = "@parameter.outer",
            ["]b"] = "@block.outer",
            ["]l"] = "@loop.outer",
            ["]i"] = "@conditional.outer",
            ["]s"] = "@statement.outer",
          },
          goto_next_end = {
            ["]F"] = "@function.outer",
            ["]C"] = "@class.outer",
            ["]A"] = "@parameter.outer",
            ["]B"] = "@block.outer",
            ["]L"] = "@loop.outer",
            ["]I"] = "@conditional.outer",
            ["]S"] = "@statement.outer",
          },
          goto_previous_start = {
            ["[f"] = "@function.outer",
            ["[c"] = "@class.outer",
            ["[a"] = "@parameter.outer",
            ["[b"] = "@block.outer",
            ["[l"] = "@loop.outer",
            ["[i"] = "@conditional.outer",
            ["[s"] = "@statement.outer",
          },
          goto_previous_end = {
            ["[F"] = "@function.outer",
            ["[C"] = "@class.outer",
            ["[A"] = "@parameter.outer",
            ["[B"] = "@block.outer",
            ["[L"] = "@loop.outer",
            ["[I"] = "@conditional.outer",
            ["[S"] = "@statement.outer",
          },
        },
        swap = {
          swap_next = {
            ["<leader>a"] = "@parameter.inner",
          },
          swap_previous = {
            ["<leader>A"] = "@parameter.inner",
          },
        },
      })
    end,
  },
}
