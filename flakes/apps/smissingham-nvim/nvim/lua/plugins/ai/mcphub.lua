return {
	-- ##### MCP HUB ##### --
	-- Config: https://ravitemer.github.io/mcphub.nvim/configuration.html
	{
		"ravitemer/mcphub.nvim",
		version = "4.2.0",
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
}
