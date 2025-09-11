vim.keymap.set("n", "<leader>la", ":LspInfo<cr>", { desc = "Lsp Info" })

-- EXPERIMENTAL Type Checker & Full LSP
vim.lsp.config("ty", {
	settings = {
		ty = {
			diagnosticmode = "workspaces",
			disableLanguageServices = false,
			experimental = {
				rename = true,
			},
		},
	},
})
vim.lsp.enable("ty")

-- Linter with basic LSP features
vim.lsp.config("ruff", {
	init_options = {
		settings = {},
	},
})
vim.lsp.enable("ruff")
