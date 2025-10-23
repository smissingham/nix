vim.lsp.config("groovyls", {
	filetypes = { "groovy" },
	cmd = { "groovyls" },
	root_markers = {
		"pom.xml",
		"build.gradle",
		".git",
	},
})
vim.lsp.enable("groovyls")
