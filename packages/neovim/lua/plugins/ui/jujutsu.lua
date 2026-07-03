return {
	{
		"yannvanhalewyn/jujutsu.nvim",
		config = function()
			require("jujutsu-nvim").setup({
				diff_preset = "diffview",
			})
		end,
	},
}
