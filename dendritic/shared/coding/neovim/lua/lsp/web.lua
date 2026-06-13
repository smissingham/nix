-- HTML, CSS and JSON language servers
vim.lsp.config("html", {
	filetypes = { "html" },
	cmd = { "vscode-html-language-server", "--stdio" },
})
vim.lsp.enable("html")

vim.lsp.config("cssls", {
	filetypes = { "css", "scss", "less" },
	cmd = { "vscode-css-language-server", "--stdio" },
})
vim.lsp.enable("cssls")

vim.lsp.config("jsonls", {
	filetypes = { "json", "jsonc" },
	cmd = { "vscode-json-language-server", "--stdio" },
})
vim.lsp.enable("jsonls")

vim.lsp.config("tailwindcss", {
	filetypes = {
		"astro",
		"css",
		"html",
		"javascript",
		"javascriptreact",
		"svelte",
		"typescript",
		"typescriptreact",
	},
	cmd = { "tailwindcss-language-server", "--stdio" },
	root_markers = {
		"tailwind.config.js",
		"tailwind.config.cjs",
		"tailwind.config.mjs",
		"tailwind.config.ts",
		"postcss.config.js",
		"postcss.config.cjs",
		"postcss.config.mjs",
		"postcss.config.ts",
		"package.json",
		".git",
	},
})
vim.lsp.enable("tailwindcss")

vim.lsp.config("eslint", {
	filetypes = {
		"astro",
		"javascript",
		"javascriptreact",
		"svelte",
		"typescript",
		"typescriptreact",
	},
	cmd = { "vscode-eslint-language-server", "--stdio" },
	root_markers = {
		"eslint.config.js",
		"eslint.config.mjs",
		"eslint.config.cjs",
		".eslintrc",
		".eslintrc.js",
		".eslintrc.cjs",
		".eslintrc.json",
		"package.json",
		".git",
	},
	settings = {
		validate = "on",
		packageManager = nil,
		useESLintClass = false,
		experimental = {},
		workingDirectory = { mode = "auto" },
		nodePath = "",
		format = true,
		quiet = false,
		onIgnoredFiles = "off",
		run = "onType",
		problems = {
			shortenToSingleLine = false,
		},
		codeAction = {
			disableRuleComment = {
				enable = true,
				location = "separateLine",
			},
			showDocumentation = {
				enable = true,
			},
		},
		rulesCustomizations = {
			{ rule = "tailwindcss/classnames-order", severity = "off" },
		},
		codeActionOnSave = {
			enable = true,
			mode = "all",
		},
	},
	before_init = function(_, config)
		local root_dir = config.root_dir

		if not root_dir then
			return
		end

		config.settings = config.settings or {}
		config.settings.workspaceFolder = {
			uri = root_dir,
			name = vim.fn.fnamemodify(root_dir, ":t"),
		}
	end,
})
vim.lsp.enable("eslint")

vim.lsp.config("vtsls", {
	filetypes = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
	},
	cmd = { "vtsls", "--stdio" },
	root_markers = {
		"tsconfig.json",
		"jsconfig.json",
		"package.json",
		".git",
	},
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

vim.lsp.config("svelte", {
	filetypes = { "svelte" },
	cmd = { "svelteserver", "--stdio" },
	root_markers = {
		"svelte.config.js",
		"svelte.config.cjs",
		"svelte.config.mjs",
		"package.json",
		".git",
	},
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

vim.lsp.config("astro", {
	filetypes = { "astro" },
	cmd = { "astro-ls", "--stdio" },
	root_markers = {
		"astro.config.mjs",
		"astro.config.js",
		"astro.config.ts",
		"package.json",
	},
})
vim.lsp.enable("astro")
