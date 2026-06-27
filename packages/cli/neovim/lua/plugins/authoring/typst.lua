return {
	{
		"chomosuke/typst-preview.nvim",
		ft = { "typst" },
		version = "1.*",
		config = function()
			require("typst-preview").setup({
				--invert_colors = "auto",
				follow_cursor = true,
			})

			require("lib.documents").setup_typst_preview()
		end,
	},
}
