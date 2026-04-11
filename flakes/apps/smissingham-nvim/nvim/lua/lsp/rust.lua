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

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client_id = args.data and args.data.client_id
    local client = client_id and vim.lsp.get_client_by_id(client_id)
    if not client or client.name ~= "rust_analyzer" then
      return
    end

    if vim.lsp.inlay_hint then
      vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
    end
  end,
})
