return {

  -- ##### MCP HUB ##### --
  {
    "ravitemer/mcphub.nvim",
    tag = "v5.9.0",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    --   build = "npm install -g mcp-hub@latest", -- Installs `mcp-hub` node binary globally
    config = function()
      require("mcphub").setup({
        auto_approve = true
      })

      -- Add keymap for MCPHub command
      vim.keymap.set('n', '<leader>am', '<cmd>MCPHub<cr>', { desc = 'Open MCPHub' })
    end
  },

  -- ##### AVANTE AGENT ##### --
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false,
    opts = {
      provider = "litellm_default",
      providers = {
        litellm_default = {
          __inherited_from = "openai",
          endpoint = "https://litellm.coeus.missingham.net/v1",
          model = "code-agent",
          api_key_name = "LITELLM_API_KEY"
        },
        openrouter = {
          __inherited_from = "openai",
          endpoint = "https://openrouter.ai/api/v1",
          --model = "anthropic/claude-4-sonnet-20250522",
          model = "google/gemini-2.5-flash-preview-05-20",
          api_key_name = "OPENROUTER_API_KEY"
        }
      },

      system_prompt = function()
        local hub = require("mcphub").get_hub_instance()
        return hub and hub:get_active_servers_prompt() or ""
      end,

      custom_tools = function()
        return {
          require("mcphub.extensions.avante").mcp_tool(),
        }
      end,

      disabled_tools = {
        "web_search"
      },
    },
    build = "make",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "echasnovski/mini.pick",
      "nvim-telescope/telescope.nvim",
      "hrsh7th/nvim-cmp",
      "ibhagwan/fzf-lua",
      "nvim-tree/nvim-web-devicons",
      "zbirenbaum/copilot.lua",
      {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            use_absolute_path = true,
          },
        },
      },
    },


  }
}
