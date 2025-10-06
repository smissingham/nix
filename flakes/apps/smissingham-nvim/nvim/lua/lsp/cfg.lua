-- Configuration and scripting language servers
vim.lsp.config("bashls", {})
vim.lsp.enable("bashls")

vim.lsp.config("lua_ls", {})
vim.lsp.enable("lua_ls")

vim.lsp.config("taplo", {})
vim.lsp.enable("taplo")

vim.lsp.config("yamlls", {})
vim.lsp.enable("yamlls")