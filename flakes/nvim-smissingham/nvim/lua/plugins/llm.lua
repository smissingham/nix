return {

	-- ##### MCP HUB ##### --
	-- Config: https://ravitemer.github.io/mcphub.nvim/configuration.html
	{
		"ravitemer/mcphub.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			require("mcphub").setup({
				auto_approve = true,
			})

			-- Add keymap for MCPHub command
			vim.keymap.set("n", "<leader>am", "<cmd>MCPHub<cr>", { desc = "Open MCPHub" })
		end,
	},

	-- ##### OPENCODE ##### --
	{
		"NickvanDyke/opencode.nvim",
		dependencies = { "folke/snacks.nvim" },
		---@type opencode.Config
		opts = {
			-- Your configuration, if any
		},
  -- stylua: ignore
  keys = {
    { '<leader>ot', function() require('opencode').toggle() end, desc = 'Toggle embedded opencode', },
    { '<leader>oa', function() require('opencode').ask() end, desc = 'Ask opencode', mode = 'n', },
    { '<leader>oa', function() require('opencode').ask('@selection: ') end, desc = 'Ask opencode about selection', mode = 'v', },
    { '<leader>op', function() require('opencode').select_prompt() end, desc = 'Select prompt', mode = { 'n', 'v', }, },
    { '<leader>on', function() require('opencode').command('session_new') end, desc = 'New session', },
    { '<leader>oy', function() require('opencode').command('messages_copy') end, desc = 'Copy last message', },
    { '<S-C-u>',    function() require('opencode').command('messages_half_page_up') end, desc = 'Scroll messages up', },
    { '<S-C-d>',    function() require('opencode').command('messages_half_page_down') end, desc = 'Scroll messages down', },
  },
	},

	-- ##### AVANTE AGENT ##### --
	{
		"yetone/avante.nvim",
		event = "VeryLazy",
		version = false,

		opts = function()
			local litellm_conf = {
				__inherited_from = "openai",
				endpoint = "https://litellm.coeus.missingham.net/v1",
				api_key_name = "LITELLM_API_KEY",
			}

			return {

				provider = "code_agent",
				auto_suggestion_provider = "code_completion",

				providers = {
					code_agent = vim.tbl_extend("force", litellm_conf, {
						model = "code-agent",
					}),
					code_completion = vim.tbl_extend("force", litellm_conf, {
						model = "code-completion",
					}),
					morph = {
						model = "auto", -- FastApply Model
					},
				},

				behaviour = {
					auto_suggestions = false,
					enable_fastapply = false,
				},

				disabled_tools = {
					"web_search",
				},

				mappings = {
					submit = {
						insert = "<C-m>", -- Ctrl + Enter
					},
					suggestion = {
						accept = "<Tab>",
						next = "<M-]>",
						prev = "<M-[>",
						dismiss = "<M-Esc>",
					},
				},

				windows = {
					input = {
						height = 10,
					},
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
			}
		end,

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
	},
}
