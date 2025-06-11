return {

  -- ##### LSPCONFIG ##### --
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        -- General Purpose, Commons, vscode-langservers-extracted --
        html = {},   -- HTML
        cssls = {},  -- CSS
        jsonls = {}, -- JSON
        eslint = {}, -- Javascript

        -- System Configuration Related --
        lua_ls = {}, -- Lua
        nixd = {},   -- Nix
        taplo = {},  -- TOML

        -- Development Projects --
        rust_analyzer = {}, -- Rust
        ts_ls = {},         -- Typescript
      }
    },
    config = function(_, opts)
      local lspconfig = require('lspconfig')
      for server, config in pairs(opts.servers) do
        config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)
        lspconfig[server].setup(config)
      end
    end
  },

  -- ##### CONFORM (FORMATTER) ##### --
  {
    'stevearc/conform.nvim',
    opts = {},
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          nix = { "nixfmt" },
          lua = { "stylua" },
          python = { "isort", "black" },
          rust = { "rustfmt", lsp_format = "fallback" },
          javascript = { "prettierd" },
          javascriptreact = { "prettierd" },
          typescript = { "prettierd" },
          typescriptreact = { "prettierd" },
          css = { "prettierd" },
          html = { "prettierd" }
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_format = "fallback",
        },
      })
    end
  },
}
