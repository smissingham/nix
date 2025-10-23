vim.lsp.config("jdtls", {
	filetypes = { "java" },
	cmd = { "jdtls" },
	root_markers = {
		"pom.xml",
		"build.gradle",
		".git",
	},
})
vim.lsp.enable("jdtls")
