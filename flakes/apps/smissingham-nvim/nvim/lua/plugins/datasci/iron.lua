return {
	{
		"Vigemus/iron.nvim",
		config = function()
			local iron = require("iron.core")
			local view = require("iron.view")
			local common = require("iron.fts.common")

			iron.setup({
				config = {
					scratch_repl = true,
					repl_open_cmd = view.split.vertical.rightbelow("33%"),
					repl_definition = {
						python = {
							command = { "ipython", "--no-autoindent" },
							block_dividers = { "# %%", "#%%" },
							format = function(lines, extras)
								local result = common.bracketed_paste_python(lines, extras)

								-- filter out comment lines
								local filtered = vim.tbl_filter(function(line)
									return not string.match(line, "^#") and not string.match(line, "^\\s*$")
								end, result)

								return filtered
							end,
						},
					},
					-- Ignore blank lines when sending visual select lines
					ignore_blank_lines = true,
				},
				keymaps = {
					-- REPL management
					toggle_repl = "<leader>ii",
					restart_repl = "<leader>iR",
					-- Send code blocks and motions
					--send_motion = "<leader>sc",
					visual_send = "<leader>is",
					send_file = "<leader>i<cr>",
					-- send_line = "<leader>sl",
					-- send_paragraph = "<leader>sp",
					-- send_until_cursor = "<leader>su",
					-- Code block functionality (key for running blocks)
					send_code_block = "<leader>i<space>",
					--send_code_block_and_move = "<leader>sn",
					-- Mark functionality
					-- send_mark = "<leader>sm",
					-- mark_motion = "<leader>mc",
					-- mark_visual = "<leader>mc",
					-- remove_mark = "<leader>md",
					-- REPL control
					--cr = "<leader>i<cr>",
					interrupt = "<leader>iC",
					exit = "<leader>iq",
					clear = "<leader>ic",
				},
				-- Highlight sent code
				highlight = {
					italic = true,
				},
			})

			-- Additional keymaps for REPL management
			vim.keymap.set("n", "<leader>if", "<cmd>IronFocus<cr>", { desc = "Focus REPL" })
			vim.keymap.set("n", "<leader>ih", "<cmd>IronHide<cr>", { desc = "Hide REPL" })
		end,
	},
}
