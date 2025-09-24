-- HTML LSP Server
vim.lsp.config("html", {})
vim.lsp.enable("html")

-- CSS LSP Server
vim.lsp.config("cssls", {})
vim.lsp.enable("cssls")

-- JSON LSP Server
vim.lsp.config("jsonls", {})
vim.lsp.enable("jsonls")

-- ESLint LSP Server
vim.lsp.config("eslint", {
	settings = {
		rulesCustomizations = {
			{ rule = "tailwindcss/classnames-order", severity = "off" },
		},
	},
})
vim.lsp.enable("eslint")

-- TypeScript LSP Server
vim.lsp.config("vtsls", {})
vim.lsp.enable("vtsls")