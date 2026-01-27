-- Rust LSP Server
vim.lsp.config("rust_analyzer", {
  root_markers = {
    "Cargo.toml"
  },
  settings = {
    ["rust-analyzer"] = {
      check = {
        command = "clippy",
      },
    },
  },
})
vim.lsp.enable("rust_analyzer")
-- Disabled, now configured by rustaceanvim plugin
