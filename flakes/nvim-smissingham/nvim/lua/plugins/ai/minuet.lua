return {
	{
		"milanglacier/minuet-ai.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			require("minuet").setup({
				-- Model Provider Configuration --
				provider = "openai_fim_compatible",
				context_window = 16000, -- Increased for better context understanding
				n_completions = 1, -- More options for better quality
				request_timeout = 5, -- Longer timeout for better results
				throttle = 1000, -- Slightly longer to reduce API pressure
				debounce = 400, -- Standard debounce
				-- Better filtering for cleaner results
				after_cursor_filter_length = 20,
				before_cursor_filter_length = 5,
				provider_options = {
					openai_fim_compatible = {
						api_key = "TERM",
						name = "ai",
						end_point = "http://localhost:1234/v1/completions",
						model = "qwen/qwen3-30b-a3b-2507",
						stream = true,
						optional = {
							max_tokens = 256, -- Balanced for quality vs speed
							top_p = 0.9, -- Better balance for creativity
							temperature = 0.2, -- Slightly higher for more natural code
							-- Add repetition penalty to avoid repetitive completions
							repetition_penalty = 1.1,
							-- Add frequency penalty
							frequency_penalty = 0.1,
						},
					},
				},

				virtualtext = {
					-- Disable automatic triggering - only manual activation
					auto_trigger_ft = {},
					keymap = {
						-- accept whole completion
						accept = "<Tab>",
						-- accept one line
						accept_line = "<C-y>",
						-- accept n lines (prompts for number)
						accept_n_lines = "<A-z>",
						-- Cycle to prev completion item, or manually invoke completion
						prev = "<C-h>",
						-- Cycle to next completion item, or manually invoke completion
						next = "<C-l>",
						dismiss = "<C-c>",
					},
				},
			})
		end,
	},
}
