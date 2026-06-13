return {
	{
		"echasnovski/mini.snippets",
		event = "InsertEnter",
		dependencies = "rafamadriz/friendly-snippets",
		opts = function()
			local mini_snippets = require("mini.snippets")
			return {
				snippets = { mini_snippets.gen_loader.from_lang() },
				expand = {
					select = function(snippets, insert)
						require("mini.snippets").default_select(snippets, insert)
					end,
				},
			}
		end,
	},
}
