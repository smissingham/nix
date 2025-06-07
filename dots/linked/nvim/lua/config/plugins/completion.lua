return {
  -- ##### BLINK CMP ##### --
  {
    'saghen/blink.cmp',
    dependencies = {
      'rafamadriz/friendly-snippets',
      'Kaiser-Yang/blink-cmp-avante',
    },
    version = '1.*',
    opts = {
      keymap = { preset = 'enter' },
      appearance = {
        nerd_font_variant = 'mono',
        use_nvim_cmp_as_default = true,
        kind_icons = {
          -- LLM Provider icons
          claude = '󰋦',
          openai = '󱢆',
          codestral = '󱎥',
          gemini = '',
          Groq = '',
          Openrouter = '󱂇',
          Ollama = '󰳆',
          LiteLLM = '🚆',
          ['Llama.cpp'] = '󰳆',
          Deepseek = ''
        }
      },
      completion = { documentation = { auto_show = true } },
      sources = {
        default = { 'lazydev', 'avante', 'lsp', 'path', 'snippets', 'buffer', 'minuet' },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            -- make lazydev completions top priority (see `:h blink.cmp`)
            score_offset = 100,
          },
          avante = {
            module = 'blink-cmp-avante',
            name = 'Avante',
            opts = {
              -- options for blink-cmp-avante
            }
          },
          minuet = {
            name = 'minuet',
            module = 'minuet.blink',
            async = true,
            -- Should match minuet.config.request_timeout * 1000,
            -- since minuet.config.request_timeout is in seconds
            timeout_ms = 3000,
            score_offset = 50, -- Gives minuet higher priority among suggestions
          },
        },
      },
      fuzzy = { implementation = "prefer_rust_with_warning" }
    },
    opts_extend = { "sources.default" }
  },

  -- ##### LAZYDEV LUA ##### --
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "snacks.nvim",        words = { "Snacks" } },
        { path = "lazy.nvim",          words = { "LazyVim" } },
      },
    },
  },
}
