-- Nix LSP Server
vim.lsp.config("nixd", {
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
})
vim.lsp.enable("nixd")