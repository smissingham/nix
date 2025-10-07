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
		codeActionOnSave = {
			enable = true,
			mode = "all",
		},
		validate = {
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
			"svelte",
		},
	},
})
vim.lsp.enable("eslint")

-- TypeScript LSP Server
vim.lsp.config("vtsls", {
	settings = {
		typescript = {
			suggest = {
				autoImports = true,
				completeFunctionCalls = true,
			},
			preferences = {
				importModuleSpecifier = "relative",
				includePackageJsonAutoImports = "auto",
			},
			updateImportsOnFileMove = {
				enabled = "always",
			},
		},
		javascript = {
			suggest = {
				autoImports = true,
				completeFunctionCalls = true,
			},
			preferences = {
				importModuleSpecifier = "relative",
				includePackageJsonAutoImports = "auto",
			},
			updateImportsOnFileMove = {
				enabled = "always",
			},
		},
		vtsls = {
			experimental = {
				completion = {
					enableServerSideFuzzyMatch = true,
				},
			},
		},
	},
})
vim.lsp.enable("vtsls")

-- Svelte LSP Server
vim.lsp.config("svelte", {
	settings = {
		svelte = {
			plugin = {
				typescript = {
					enable = true,
					diagnostics = { enable = true },
				},
				css = { enable = true },
				html = { enable = true },
			},
		},
	},
})
vim.lsp.enable("svelte")