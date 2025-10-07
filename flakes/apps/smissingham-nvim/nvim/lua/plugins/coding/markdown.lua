vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if vim.fn.getcwd():match("^" .. vim.fn.expand("~") .. "/Documents/Obsidian/") then
			require("lazy").load({ plugins = { "obsidian.nvim" } })
		end
	end,
})

return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		opts = {
			file_types = {
				--"markdown",
				"Avante",
			},
		},
	},
	{
		"epwalsh/obsidian.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		version = "*",
		lazy = true,
		event = {},
		opts = {
			workspaces = {
				{
					name = "second-brain",
					path = "~/Documents/Obsidian/second-brain/",
				},
				{
					name = "family",
					path = "~/Documents/Obsidian/family/",
				},
			},
			notes_subdir = "Slipbox",
			new_notes_location = "notes_subdir",
			note_id_func = function(title)
				title = title or "Quick Note"
				local prefix = os.date("%Y-%m-%d ")
				return prefix .. title
			end,
		},
		keys = {
			{ "<leader>oo", "<cmd>ObsidianOpen<cr>", desc = "Obsidian Open" },
			{ "<leader>on", "<cmd>ObsidianNew<cr>", desc = "Obsidian New" },
		},
	},
}
