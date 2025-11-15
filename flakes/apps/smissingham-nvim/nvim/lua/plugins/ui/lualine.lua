return {
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
		require("lualine").setup({
			sections = {
				lualine_c = {
					{
						"filename",
						path = 1, -- 0 = just filename, 1 = relative path, 2 = absolute path
					},
				},
				lualine_x = {
					{ require("minuet.lualine") },
					"encoding",
					"fileformat",
					"filetype",
				},
			},
		})
		end,
	},
}
