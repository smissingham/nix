return {
	{ "virchau13/tree-sitter-astro" },
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local ts = require("nvim-treesitter")
			ts.setup()

			vim.api.nvim_create_autocmd("FileType", {
				callback = function()
					local ok = pcall(vim.treesitter.start)
					if not ok then
						return
					end

					vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})

			ts.install({
				-- Vim Related
				"lua",
				"vim",
				"vimdoc",
				"query",

				-- Text / Publishing
				"latex",
				"markdown",
				"markdown_inline",

				-- Shell / Sysops
				"nix",
				"nu",
				"just",
				"bash",
				"toml",
				"yaml",

				-- Programming
				"python",
				"sql",
				"rust",
				"java",
				"groovy",

				-- Web
				"css",
				"scss",
				"html",
				"html_tags",
				"json",
				"astro",
				"javascript",
				"jsx",
				"typescript",
				"tsx",
				"svelte",
				"vue",
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		init = function()
			vim.g.no_plugin_maps = true
		end,
	},
}
