return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				-- General Purpose, Commons, vscode-langservers-extracted --
				html = {}, -- HTML
				cssls = {}, -- CSS
				jsonls = {}, -- JSON
				eslint = {
					settings = {
						rulesCustomizations = {
							{ rule = "tailwindcss/classnames-order", severity = "off" },
						},
					},
				}, -- Javascript

				-- System Configuration Related --
				bashls = {},
				lua_ls = {}, -- Lua
				nixd = {
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
				}, -- Nix
				taplo = {}, -- TOML

				-- Development Projects --
				rust_analyzer = {}, -- Rust
				--ts_ls = {},         -- Typescript
				vtsls = {}, -- Better Typescript

				-- jdtls = {
				-- 	filetypes = { "java", "groovy" },
				-- 	cmd = { "jdtls", "--jvm-arg=-Dfile.encoding=UTF-8" },
				-- },

				groovyls = {
					filetypes = { "groovy" },
					cmd = { "groovyls" },
				},
			},
		},
		config = function(_, opts)
			local lspconfig = require("lspconfig")
			for server, config in pairs(opts.servers) do
				config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)

				-- if server == "jdtls" then
				-- 	config.root_dir = require("lspconfig.util").root_pattern("build.gradle", "pom.xml", ".git")
				-- end

				if server == "groovyls" then
					config.root_dir = lspconfig.util.root_pattern("build.gradle", "pom.xml", ".git")
				end

				lspconfig[server].setup(config)
			end
		end,
	},
}
