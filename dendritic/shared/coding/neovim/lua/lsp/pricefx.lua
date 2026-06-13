vim.lsp.config("pricefx-lsp", {
  filetypes = { "groovy" },
  cmd = { "pricefx-lsp" },
  root_markers = {
    "pom.xml",
    ".git",
  },
})
--vim.lsp.enable("pricefx-lsp")
