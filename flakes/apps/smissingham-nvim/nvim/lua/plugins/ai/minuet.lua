-- VectorCode integration for RAG
local has_vc, vectorcode_config = pcall(require, "vectorcode.config")
local vectorcode_cacher = nil
if has_vc then
	vectorcode_cacher = vectorcode_config.get_cacher_backend()
end

-- Reusable FIM template with RAG support
local function create_fim_template_with_rag(rag_context_window_size)
	rag_context_window_size = rag_context_window_size or 8000 -- roughly 2k tokens
	return {
		prompt = function(context_before_cursor, context_after_cursor, opts)
			-- Get RAG context from VectorCode
			local rag_context = ""
			if has_vc then
				local cache_result = vectorcode_cacher.query_from_cache(0)
				for _, file in ipairs(cache_result) do
					rag_context = rag_context .. "<|file_sep|>" .. file.path .. "\n" .. file.document
				end
				rag_context = vim.fn.strcharpart(rag_context, 0, rag_context_window_size)
			end

			return rag_context
				.. "# language: "
				.. vim.bo.filetype
				.. "\n"
				.. "# IMPORTANT: Only complete with English code/comments. No Chinese characters.\n"
				.. "<|fim_prefix|>"
				.. context_before_cursor
				.. "<|fim_suffix|>"
				.. context_after_cursor
				.. "<|fim_middle|>"
		end,
		suffix = false,
	}
end

local models = {
	qwen3_coder_small = {
		provider = "openai_fim_compatible",
		provider_options = {
			api_key = "TERM",
			name = "LmStudio",
			end_point = "http://localhost:1234/v1/completions",
			model = "qwen/qwen3-30b-a3b-2507",
			stream = true,
			optional = {
				max_tokens = 64,
				top_p = 0.9,
				temperature = 0.15,
				repetition_penalty = 1.1,
				frequency_penalty = 0.1,
			},
			template = create_fim_template_with_rag(2000),
		},
	},
	qwen3_coder_large = {
		provider = "openai_fim_compatible",
		provider_options = {
			name = "OpenRouter",
			model = "qwen/qwen3-coder",
			api_key = "OPENROUTER_API_KEY",
			end_point = "https://openrouter.ai/api/v1/completions",
			stream = true,
			optional = {
				max_tokens = 256,
				top_p = 0.9,
				temperature = 0.3,
				repetition_penalty = 1.1,
				frequency_penalty = 0.1,
			},
			template = create_fim_template_with_rag(),
		},
	},
	kimik2 = {
		provider = "openai_compatible",
		provider_options = {
			name = "OpenRouter",
			model = "moonshotai/kimi-k2-0905",
			api_key = "OPENROUTER_API_KEY",
			end_point = "https://openrouter.ai/api/v1/chat/completions",
			stream = true,
			optional = {
				max_tokens = 256,
				top_p = 0.9,
				temperature = 0.3,
				repetition_penalty = 1.1,
				frequency_penalty = 0.1,
			},
		},
	},
}

return {
	-- VectorCode for RAG functionality
	{
		"Davidyz/VectorCode",
		config = function()
			require("vectorcode").setup({
				n_query = 3,
			})
		end,
	},
	-- Minuet Completion
	{
		"milanglacier/minuet-ai.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"Davidyz/VectorCode",
		},
		config = function()
			local model = models.kimik2

			require("minuet").setup({
				provider = model.provider,
				provider_options = {
					[model.provider] = model.provider_options,
				},

				context_window = 8192,
				n_completions = 1,
				request_timeout = 60,
				throttle = 1000,
				debounce = 400,

				--after_cursor_filter_length = 20,
				--before_cursor_filter_length = 5,

				virtualtext = {
					auto_trigger_ft = {},
					keymap = {
						accept = "<C-a>",
						accept_n_lines = "<C-y>",
						accept_line = "<C-u>",
						prev = "<C-h>",
						next = "<C-l>",
						dismiss = "<C-c>",
					},
				},
			})

			-- Set up VectorCode keymaps
			vim.keymap.set("n", "<leader>vr", ":VectorCode register<CR>", { desc = "Register buffer with VectorCode" })
			vim.keymap.set("n", "<leader>vi", ":VectorCode index<CR>", { desc = "Index project with VectorCode" })
		end,
	},
}
