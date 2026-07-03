vim.lsp.config("tinymist", {
	filetypes = { "typst" },
	cmd = { "tinymist" },
	root_markers = {
		"typst.toml",
		".git",
	},
})
vim.lsp.enable("tinymist")
