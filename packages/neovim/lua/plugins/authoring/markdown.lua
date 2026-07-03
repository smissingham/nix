return {
	{
		"iamcco/markdown-preview.nvim",
		ft = { "markdown" },
		cmd = {
			"MarkdownPreview",
			"MarkdownPreviewStop",
			"MarkdownPreviewToggle",
		},
		build = "cd app && bun install",
		init = function()
			vim.g.mkdp_auto_start = 0
			vim.g.mkdp_auto_close = 0
			vim.g.mkdp_refresh_slow = 0
			vim.g.mkdp_echo_preview_url = 1
		end,
		config = function()
			require("lib.documents").setup_markdown_preview()
		end,
	},
}
