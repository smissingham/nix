return {
	{
		"Vigemus/iron.nvim",
		config = function()
			local iron = require("iron.core")
			local view = require("iron.view")

			iron.setup({
				config = {
					repl_open_cmd = view.right("33%"),
				},
				keymaps = {
					toggle_repl = "<space>ir",
					restart_repl = "<space>iR",
				},
			})
		end,
	},
}
