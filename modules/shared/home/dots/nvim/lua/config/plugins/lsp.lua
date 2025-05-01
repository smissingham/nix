return {
    {
	"neovim/nvim-lspconfig",
	config = function()
	    local lsp = require("lspconfig")

	    -- To list others, from inside neovim `:help lspconfig-all`
	    lsp.lua_ls.setup{}
	    lsp.nixd.setup{}
	end
    }
}
