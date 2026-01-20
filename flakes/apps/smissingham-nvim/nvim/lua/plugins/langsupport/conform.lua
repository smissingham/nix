return {
  {
    "stevearc/conform.nvim",
    opts = {},
    config = function()
      vim.filetype.add({
        pattern = {
          [".*%.justfile"] = "just",
          ["[Jj]ustfile"] = "just",
        },
      })

      require("conform").setup({
        formatters_by_ft = {
          sh = { "shfmt" },
          bashsh = { "shfmt" },
          nix = { "nixfmt" },
          black = { "black" },


          --prettierd = {"prettierd"},
          html = { "prettierd" },
          css = { "prettierd" },
          javascript = { "prettierd" },
          javascriptreact = { "prettierd" },
          typescript = { "prettierd" },
          typescriptreact = { "prettierd" },
          svelte = { "prettierd" },
          astro = { "prettierd" },


          ["_"] = {
            lsp_format = "prefer",
          },
        },

        format_on_save = {
          timeout_ms = 1000,
          lsp_format = "fallback",
        },
      })

      -- Keymap for formatting with conform
      vim.keymap.set({ "n", "v" }, "<leader>cf", function()
        require("conform").format({
          lsp_fallback = true,
          async = false,
          timeout_ms = 1000,
        })
      end, { desc = "Code format" })
    end,
  },
}
