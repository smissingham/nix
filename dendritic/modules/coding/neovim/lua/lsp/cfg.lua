-- Configuration and scripting language servers
vim.lsp.config("bashls", {
  filetypes = { "bash", "sh" },
  cmd = { "bash-language-server", "start" },
})
vim.lsp.enable("bashls")

vim.lsp.config("nushell", {
  filetypes = {
    "nu",
    "justfile"
  },
  cmd = { "nu", "--lsp" },
})
vim.lsp.enable("nushell")

vim.lsp.config("taplo", {
  filetypes = { "toml" },
  cmd = { "taplo", "lsp", "stdio" },
})
vim.lsp.enable("taplo")

vim.lsp.config("yamlls", {
  filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab" },
  cmd = { "yaml-language-server", "--stdio" },
})
vim.lsp.enable("yamlls")
