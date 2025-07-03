return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = 'master',
    lazy = false,
    build = ":TSUpdate",
    init = function()
      -- Disable LSP diagnostics for treesitter files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "query" },
        callback = function()
          vim.diagnostic.disable(0)
        end,
      })
    end,
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "vim", "vimdoc", "query" },
        sync_install = false,
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter.configs").setup({
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
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
            enable = true,
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
            enable = true,
            swap_next = {
              ["<leader>a"] = "@parameter.inner",
            },
            swap_previous = {
              ["<leader>A"] = "@parameter.inner",
            },
          },
        },
      })
    end
  }
}
