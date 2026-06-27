return {
	{
		"folke/snacks.nvim",
		dependencies = "nvim-tree/nvim-web-devicons",
		priority = 1000,
		lazy = false,
		---@type snacks.Config
		opts = {
			bigfile = { enabled = true },
			dashboard = {
				enabled = true,
				sections = {
					{
						text = {
							{ "  Neovim\n", hl = "SnacksDashboardHeader" },
							{
								string.format(
									"v%d.%d.%d",
									vim.version().major,
									vim.version().minor,
									vim.version().patch
								),
								hl = "SnacksDashboardDesc",
							},
						},
						align = "center",
						padding = 1,
					},
					{ section = "keys", gap = 1, padding = 1 },
					{
						pane = 2,
						icon = "⏳",
						title = "Recent Files",
						section = "recent_files",
						cwd = true,
						indent = 2,
						padding = 1,
					},
					{
						pane = 2,
						icon = " ",
						title = "Git Status",
						section = "terminal",
						enabled = function()
							return Snacks.git.get_root() ~= nil
						end,
						cmd = { "git", "-c", "color.status=always", "status", "--short", "--branch" },
						height = 5,
						padding = 1,
						ttl = 5 * 60,
						indent = 1,
					},
					{
						icon = "🖥️",
						title = "Sys Info",
						section = "terminal",
						cmd = { "fastfetch", "--logo", "none", "-s", "title:os:kernel:cpu:memory:disk" },
						ttl = 0,
						pane = 2,
						height = 8,
						padding = 1,
					},
				},
			},
			explorer = {
				enabled = true,
				replace_netrw = true,
				modifiable = true,
				ignored = true,
			},
			indent = { enabled = true },
			input = { enabled = true },
			lazygit = { enabled = true },
			notifier = {
				enabled = true,
				timeout = 3000,
			},
			picker = {
				enabled = true,
				sources = {
					explorer = {
						hidden = true,
						ignored = true,
					},
					files = {
						hidden = true,
					},
					lsp_symbols = {
						layout = {
							preset = "right",
							layout = {
								min_width = 20,
							},
						},
					},
				},
				include = {
					".env",
				},
				layouts = {
					default = {
						reverse = true,
						layout = {
							backdrop = false,
							width = 0.95,
							height = 0.95,
							border = "rounded",
							box = "vertical",
							{ win = "preview", title = "{preview}", height = 0.75, border = "bottom" },
							{ win = "list", border = "none" },
							{
								win = "input",
								height = 1,
								border = "top",
								title = "{title} {live} {flags}",
								title_pos = "center",
							},
						},
					},
					sidebar = {
						preview = "main",
						layout = {
							backdrop = false,
							width = 40,
							height = 0,
							position = "left",
							border = "none",
							box = "vertical",
							{
								win = "input",
								height = 1,
								border = true,
								title = "{title} {live} {flags}",
								title_pos = "center",
							},
							{ win = "list", border = "none" },
							{ win = "preview", title = "{preview}", height = 0.4, border = "top" },
						},
					},
				},
				layout = function(source)
					if source == "explorer" then
						return "sidebar"
					end
					return "default"
				end,
				win = {
					input = {
						keys = {
							["<PageUp>"] = { "preview_scroll_up", mode = { "n", "i" } },
							["<PageDown>"] = { "preview_scroll_down", mode = { "n", "i" } },
						},
					},
				},
			},
			quickfile = { enabled = true },
			scope = {
				enabled = true,
				treesitter = {
					injections = false,
				},
			},
			scroll = { enabled = true },
			statuscolumn = { enabled = true },
			words = { enabled = true },
			styles = {
				notification = {
					-- wo = { wrap = true } -- Wrap notifications
				},
			},
		},
		keys = {
			-- top pickers & explorer
			-- {
			-- 	"<leader><space>",
			-- 	function()
			-- 		Snacks.picker.smart({ filter = { cwd = true } })
			-- 	end,
			-- 	desc = "smart find files",
			-- },
			{
				"<leader>,",
				function()
					Snacks.picker.buffers({ filter = { cwd = true } })
				end,
				desc = "buffers",
			},
			{
				"<leader>/",
				function()
					Snacks.picker.grep({ cwd = vim.uv.cwd() })
				end,
				desc = "grep",
			},
			{
				"<leader>:",
				function()
					Snacks.picker.command_history()
				end,
				desc = "command history",
			},
			{
				"<leader>n",
				function()
					Snacks.picker.notifications()
				end,
				desc = "notification history",
			},
			{
				"<leader>e",
				function()
					Snacks.explorer()
				end,
				desc = "file explorer",
			},
			-- find
			{
				"<leader>fb",
				function()
					Snacks.picker.buffers({ filter = { cwd = true } })
				end,
				desc = "buffers",
			},
			{
				"<leader>fc",
				function()
					Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
				end,
				desc = "find config file",
			},
			{
				"<leader>ff",
				function()
					Snacks.picker.files({ cwd = vim.uv.cwd() })
				end,
				desc = "find files",
			},
			{
				"<leader>sg",
				function()
					Snacks.picker.git_files({ cwd = vim.uv.cwd() })
				end,
				desc = "find git files",
			},
			{
				"<leader>fp",
				function()
					Snacks.picker.projects()
				end,
				desc = "projects",
			},
			{
				"<leader>fr",
				function()
					Snacks.picker.recent({ filter = { cwd = true } })
				end,
				desc = "recent",
			},
			-- git
			{
				"<leader>gb",
				function()
					Snacks.picker.git_branches()
				end,
				desc = "git branches",
			},
			{
				"<leader>gl",
				function()
					Snacks.picker.git_log()
				end,
				desc = "git log",
			},
			{
				"<leader>gl",
				function()
					Snacks.picker.git_log_line()
				end,
				desc = "git log line",
			},
			{
				"<leader>gs",
				function()
					Snacks.picker.git_status()
				end,
				desc = "git status",
			},
			{
				"<leader>gs",
				function()
					Snacks.picker.git_stash()
				end,
				desc = "git stash",
			},
			{
				"<leader>gd",
				function()
					Snacks.picker.git_diff()
				end,
				desc = "git diff (hunks)",
			},
			{
				"<leader>gf",
				function()
					Snacks.picker.git_log_file()
				end,
				desc = "git log file",
			},
			-- grep
			{
				"<leader>sb",
				function()
					Snacks.picker.lines()
				end,
				desc = "buffer lines",
			},
			{
				"<leader>sb",
				function()
					Snacks.picker.grep_buffers({ filter = { cwd = true } })
				end,
				desc = "grep open buffers",
			},
			{
				"<leader>sg",
				function()
					Snacks.picker.grep({ cwd = vim.uv.cwd() })
				end,
				desc = "grep",
			},
			{
				"<leader>sw",
				function()
					Snacks.picker.grep_word({ cwd = vim.uv.cwd() })
				end,
				desc = "visual selection or word",
				mode = { "n", "x" },
			},
			-- search
			{
				'<leader>s"',
				function()
					Snacks.picker.registers()
				end,
				desc = "registers",
			},
			{
				"<leader>s/",
				function()
					Snacks.picker.search_history()
				end,
				desc = "search history",
			},
			{
				"<leader>sa",
				function()
					Snacks.picker.autocmds()
				end,
				desc = "autocmds",
			},
			{
				"<leader>sb",
				function()
					Snacks.picker.lines()
				end,
				desc = "buffer lines",
			},
			{
				"<leader>sc",
				function()
					Snacks.picker.command_history()
				end,
				desc = "command history",
			},
			{
				"<leader>sc",
				function()
					Snacks.picker.commands()
				end,
				desc = "commands",
			},
			{
				"<leader>sd",
				function()
					Snacks.picker.diagnostics()
				end,
				desc = "diagnostics",
			},
			{
				"<leader>sd",
				function()
					Snacks.picker.diagnostics_buffer()
				end,
				desc = "buffer diagnostics",
			},
			{
				"<leader>sh",
				function()
					Snacks.picker.help()
				end,
				desc = "help pages",
			},
			{
				"<leader>sh",
				function()
					Snacks.picker.highlights()
				end,
				desc = "highlights",
			},
			{
				"<leader>si",
				function()
					Snacks.picker.icons()
				end,
				desc = "icons",
			},
			{
				"<leader>sj",
				function()
					Snacks.picker.jumps()
				end,
				desc = "jumps",
			},
			{
				"<leader>sk",
				function()
					Snacks.picker.keymaps()
				end,
				desc = "keymaps",
			},
			{
				"<leader>sl",
				function()
					Snacks.picker.loclist()
				end,
				desc = "location list",
			},
			{
				"<leader>sm",
				function()
					Snacks.picker.marks()
				end,
				desc = "marks",
			},
			{
				"<leader>sm",
				function()
					Snacks.picker.man()
				end,
				desc = "man pages",
			},
			{
				"<leader>sp",
				function()
					Snacks.picker.lazy()
				end,
				desc = "search for plugin spec",
			},
			{
				"<leader>sq",
				function()
					Snacks.picker.qflist()
				end,
				desc = "quickfix list",
			},
			{
				"<leader>sr",
				function()
					Snacks.picker.resume()
				end,
				desc = "resume",
			},
			{
				"<leader>su",
				function()
					Snacks.picker.undo()
				end,
				desc = "undo history",
			},
			{
				"<leader>sz",
				function()
					Snacks.picker.zoxide()
				end,
				desc = "search zoxide projects",
			},
			{
				"<leader>uc",
				function()
					Snacks.picker.colorschemes()
				end,
				desc = "colorschemes",
			},
			-- lsp
			{
				"gd",
				function()
					Snacks.picker.lsp_definitions()
				end,
				desc = "goto definition",
			},
			{
				"gd",
				function()
					Snacks.picker.lsp_declarations()
				end,
				desc = "goto declaration",
			},
			{
				"gr",
				function()
					Snacks.picker.lsp_references()
				end,
				nowait = true,
				desc = "references",
			},
			{
				"gi",
				function()
					Snacks.picker.lsp_implementations()
				end,
				desc = "goto implementation",
			},
			{
				"gy",
				function()
					Snacks.picker.lsp_type_definitions()
				end,
				desc = "goto t[y]pe definition",
			},
			{
				"<leader>ss",
				function()
					Snacks.picker.lsp_symbols()
				end,
				desc = "lsp symbols",
			},
			{
				"<leader>ss",
				function()
					Snacks.picker.lsp_workspace_symbols()
				end,
				desc = "lsp workspace symbols",
			},
			{
				"<leader><enter>",
				function()
					Snacks.picker.lsp_workspace_symbols()
				end,
				desc = "lsp workspace symbols",
			},
			-- other
			{
				"<leader>z",
				function()
					Snacks.zen()
				end,
				desc = "toggle zen mode",
			},
			{
				"<leader>z",
				function()
					Snacks.zen.zoom()
				end,
				desc = "toggle zoom",
			},
			{
				"<leader>.",
				function()
					Snacks.scratch()
				end,
				desc = "toggle scratch buffer",
			},
			{
				"<leader>s",
				function()
					Snacks.scratch.select()
				end,
				desc = "select scratch buffer",
			},
			{
				"<leader>n",
				function()
					Snacks.notifier.show_history()
				end,
				desc = "notification history",
			},
			{
				"<leader>bd",
				function()
					Snacks.bufdelete()
				end,
				desc = "delete buffer",
			},
			{
				"<leader>cr",
				function()
					Snacks.rename.rename_file()
				end,
				desc = "rename file",
			},
			{
				"<leader>gb",
				function()
					Snacks.gitbrowse()
				end,
				desc = "git browse",
				mode = { "n", "v" },
			},
			{
				"<leader>gg",
				function()
					Snacks.lazygit()
				end,
				desc = "lazygit",
			},
			{
				"<leader>un",
				function()
					Snacks.notifier.hide()
				end,
				desc = "dismiss all notifications",
			},
			{
				"<c-/>",
				function()
					Snacks.terminal()
				end,
				desc = "toggle terminal",
			},
			{
				"<c-_>",
				function()
					Snacks.terminal()
				end,
				desc = "which_key_ignore",
			},
			{
				"]]",
				function()
					Snacks.words.jump(vim.v.count1)
				end,
				desc = "next reference",
				mode = { "n", "t" },
			},
			{
				"[[",
				function()
					Snacks.words.jump(-vim.v.count1)
				end,
				desc = "prev reference",
				mode = { "n", "t" },
			},
			{
				"<leader>n",
				desc = "neovim news",
				function()
					Snacks.win({
						file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
						width = 0.6,
						height = 0.6,
						wo = {
							spell = false,
							wrap = false,
							signcolumn = "yes",
							statuscolumn = " ",
							conceallevel = 3,
						},
					})
				end,
			},
			{
				"<leader>c",
				desc = "terminal code agent popup",
				function()
					Snacks.terminal("opencode", {
						win = {
							title = "opencode",
							width = 0.9,
							height = 0.8,
						},
					})
				end,
			},
			{
				"<leader>w",
				desc = "personal shortcuts documentation",
				function()
					Snacks.win({
						file = vim.fn.expand(
							"~/documents/obsidian/second-brain/@public/software engineering/neovim & tmux.md"
						),
						width = 0.8,
						height = 0.8,
						wo = {
							spell = false,
							wrap = false,
							signcolumn = "yes",
							statuscolumn = " ",
							conceallevel = 3,
						},
					})
				end,
			},
		},
		init = function()
			vim.api.nvim_create_autocmd("User", {
				pattern = "VeryLazy",
				callback = function()
					-- Setup some globals for debugging (lazy-loaded)
					_G.dd = function(...)
						Snacks.debug.inspect(...)
					end
					_G.bt = function()
						Snacks.debug.backtrace()
					end
					vim.print = _G.dd -- Override print to use snacks for `:=` command

					-- Create some toggle mappings
					Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
					Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
					Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
					Snacks.toggle.diagnostics():map("<leader>ud")
					Snacks.toggle.line_number():map("<leader>ul")
					Snacks.toggle
						.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
						:map("<leader>uc")
					Snacks.toggle.treesitter():map("<leader>uT")
					Snacks.toggle
						.option("background", { off = "light", on = "dark", name = "Dark Background" })
						:map("<leader>ub")
					Snacks.toggle.inlay_hints():map("<leader>uh")
					Snacks.toggle.indent():map("<leader>ug")
					Snacks.toggle.dim():map("<leader>uD")
				end,
			})
		end,
	},
}
