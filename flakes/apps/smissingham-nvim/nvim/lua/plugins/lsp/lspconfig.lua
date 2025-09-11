return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				-- #################### General Purpose #################### --
				html = {}, -- HTML
				cssls = {}, -- CSS
				jsonls = {}, -- JSON
				eslint = { -- JavaScript
					settings = {
						rulesCustomizations = {
							{ rule = "tailwindcss/classnames-order", severity = "off" },
						},
					},
				},

				-- #################### Software Development #################### --
				rust_analyzer = {}, -- Rust
				vtsls = {}, -- TypeScript
				groovyls = { -- Groovy
					filetypes = { "groovy" },
					cmd = { "groovyls" },
				},
				-- pylsp = { -- Python
				-- 	plugins = {
				-- 		-- Super fast linting & formatting
				-- 		ruff = { enabled = true },
				--
				-- 		-- Type checking
				-- 		pylsp_mypy = { enabled = true },
				--
				-- 		-- Core completion/navigation
				-- 		jedi_completion = { enabled = true },
				-- 		jedi_hover = { enabled = true },
				-- 		jedi_references = { enabled = true },
				-- 		jedi_signature_help = { enabled = true },
				-- 		jedi_symbols = { enabled = true },
				--
				-- 		-- Disable conflicting linters since ruff handles them
				-- 		pycodestyle = { enabled = false },
				-- 		pyflakes = { enabled = false },
				-- 		mccabe = { enabled = false },
				-- 		pylint = { enabled = false },
				-- 	},
				-- },

				-- #################### Systems Configuration #################### --
				bashls = {}, -- Bash/Sh
				lua_ls = {}, -- Lua
				taplo = {}, -- TOML
				nixd = { -- Nix
					settings = {
						nixd = {
							nixpkgs = {
								expr = 'import (builtins.getFlake ("git+file://" + toString ./.)).inputs.nixpkgs { }',
							},
							formatting = {
								command = { "nixfmt" },
							},
							options = {
								nixos = {
									expr = '(let pkgs = import (builtins.getFlake ("git+file://" + toString ./.)).inputs.nixpkgs { }; in (pkgs.lib.evalModules { modules = (import (builtins.getFlake ("git+file://" + toString ./.)).inputs.nixpkgs + "/nixos/modules/module-list.nix") ++ [ ({...}: { nixpkgs.hostPlatform = builtins.currentSystem; }) ]; })).options',
								},
								home_manager = {
									expr = '(let pkgs = import (builtins.getFlake ("git+file://" + toString ./.)).inputs.nixpkgs { }; lib = import ((builtins.getFlake ("git+file://" + toString ./.)).inputs.home-manager + "/modules/lib/stdlib-extended.nix") pkgs.lib; in (lib.evalModules { modules = (import ((builtins.getFlake ("git+file://" + toString ./.)).inputs.home-manager + "/modules/modules.nix")) { inherit lib pkgs; check = false; }; })).options',
								},
							},
						},
					},
				},
			},
		},
		config = function(_, opts)
			local lspconfig = require("lspconfig")
			for server, config in pairs(opts.servers) do
				-- Provide blink.cmp with server capabilities
				config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)

				-- Special rules for groovy projects
				if server == "groovyls" then
					config.root_dir = lspconfig.util.root_pattern("build.gradle", "pom.xml", ".git")
				end

				lspconfig[server].setup(config)
			end
		end,
	},
}
