-- Groovy LSP Server for Java projects
vim.lsp.config("groovyls", {
	filetypes = { "groovy" },
	cmd = { "groovyls" },
	root_dir = function()
		return vim.fs.root(0, {"build.gradle", "pom.xml", ".git"})
	end,
})
vim.lsp.enable("groovyls")