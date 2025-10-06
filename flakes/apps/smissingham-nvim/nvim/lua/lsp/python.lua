-- -- EXPERIMENTAL Type Checker & Full LSP
-- vim.lsp.config("ty", {
-- 	settings = {
-- 		ty = {
-- 			diagnosticmode = "workspaces",
-- 			disableLanguageServices = false,
-- 			experimental = {
-- 				rename = true,
-- 			},
-- 		},
-- 	},
-- })
-- vim.lsp.enable("ty"

-- Linting, formatting and imports
vim.lsp.config("ruff", {
	init_options = {
		settings = {
			fixAll = true,
		},
	},
	root_markers = {
		"uv.toml",
		"pyproject.toml",
		"requirements.txt",
		".git",
	},
})
vim.lsp.enable("ruff")

-- Type checking and document symbols
vim.lsp.config("pyrefly", {
	cmd = { "pyrefly", "lsp" },
	root_markers = {
		"uv.toml",
		"pyproject.toml",
		"requirements.txt",
		".git",
	},
	settings = {
		pyrefly = {
			disableLanguageServices = true,
		},
	},
})
vim.lsp.enable("pyrefly")
