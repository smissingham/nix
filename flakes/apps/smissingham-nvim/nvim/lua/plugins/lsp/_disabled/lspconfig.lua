return {
	{
		"neovim/nvim-lspconfig",
		-- Keep lspconfig as a dependency for the individual LSP files,
		-- but no longer configure servers here - using new vim.lsp API instead
	},
}
