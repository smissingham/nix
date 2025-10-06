return {
	{
		"christoomey/vim-tmux-navigator",
		cmd = {
			"TmuxNavigateLeft",
			"TmuxNavigateDown",
			"TmuxNavigateUp",
			"TmuxNavigateRight",
			"TmuxNavigatePrevious",
			"TmuxNavigatorProcessList",
		},
		keys = {
			{ "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>", mode = "n" },
			{ "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>", mode = "n" },
			{ "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>", mode = "n" },
			{ "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>", mode = "n" },
			{ "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>", mode = "n" },
			{
				"<c-h>",
				function()
					vim.cmd("TmuxNavigateLeft")
				end,
				mode = "t",
			},
			{
				"<c-j>",
				function()
					vim.cmd("TmuxNavigateDown")
				end,
				mode = "t",
			},
			{
				"<c-k>",
				function()
					vim.cmd("TmuxNavigateUp")
				end,
				mode = "t",
			},
			{
				"<c-l>",
				function()
					vim.cmd("TmuxNavigateRight")
				end,
				mode = "t",
			},
			{
				"<c-\\>",
				function()
					vim.cmd("TmuxNavigatePrevious")
				end,
				mode = "t",
			},
		},
		init = function()
			vim.api.nvim_create_autocmd("TermOpen", {
				callback = function()
					vim.keymap.set("t", "<C-h>", function()
						vim.cmd("TmuxNavigateLeft")
					end, { buffer = true })
					vim.keymap.set("t", "<C-j>", function()
						vim.cmd("TmuxNavigateDown")
					end, { buffer = true })
					vim.keymap.set("t", "<C-k>", function()
						vim.cmd("TmuxNavigateUp")
					end, { buffer = true })
					vim.keymap.set("t", "<C-l>", function()
						vim.cmd("TmuxNavigateRight")
					end, { buffer = true })
				end,
			})
		end,
	},
}
