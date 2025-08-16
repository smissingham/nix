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
			},
		},
		config = function(_, opts)
			local lspconfig = require("lspconfig")
			for server, config in pairs(opts.servers) do
				config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
				lspconfig[server].setup(config)
			end
		end,
	},
}
