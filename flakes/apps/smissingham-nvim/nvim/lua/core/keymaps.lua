vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- General Globals
vim.keymap.set("n", "<esc><esc>", ":noh<CR>", { noremap = true, silent = true })

-- Text Processing

-- Buffer Navigation
vim.keymap.set("n", "<Tab>", "<cmd>bnext<CR>", {})
vim.keymap.set("n", "<S-Tab>", "<cmd>bprev<CR>", {})

-- Word / Line Navigation
vim.keymap.set({ "n", "v" }, "H", "^")
vim.keymap.set({ "n", "v" }, "L", "$")

-- Config Sourcing & Reloading
vim.keymap.set("n", "<leader>xr", ":ReloadConfig<CR>", { desc = "Reload config" })
vim.keymap.set("n", "<leader>xs", ":update<cr> :source<cr>", { desc = "Write & Source Buffer" })

-- Buffer Actions
vim.keymap.set({ "n", "v" }, "<leader>bd", ":bd!<cr>", { desc = "Delete Buffer (Forced)" })
vim.keymap.set({ "n", "v" }, "<leader>bw", ":w!<cr>", { desc = "Write Buffer (Forced)" })
vim.keymap.set({ "n", "v" }, "<leader>be", ":e!<cr>", { desc = "Reset Buffer (Forced)" })

-- LSP
vim.keymap.set({ "n", "v" }, "<leader>lI", ":checkhealth vim.lsp<cr>", { desc = "Lsp Info" })
vim.keymap.set({ "n", "v" }, "<leader>lR", ":LspRestart<cr>", { desc = "Lsp Restart" })
vim.keymap.set({ "n", "v" }, "<leader>lS", ":LspStop<cr>", { desc = "Lsp Stop" })

-- Coding with Symbols & Lsp
vim.keymap.set({ "n", "v" }, "<leader>grn", vim.lsp.buf.rename, { desc = "Rename" })
vim.keymap.set({ "n", "v" }, "<leader>grr", vim.lsp.buf.references, { desc = "References" })
vim.keymap.set({ "n", "v" }, "<leader>gri", vim.lsp.buf.implementation, { desc = "Go to Implementation" })
vim.keymap.set({ "n", "v" }, "<leader>gra", vim.lsp.buf.code_action, { desc = "Code Actions" })
vim.keymap.set({ "n", "v" }, "<leader>gds", vim.lsp.buf.document_symbol, { desc = "Document Symbols" })
vim.keymap.set({ "n", "v" }, "<leader>gdh", vim.lsp.buf.document_highlight, { desc = "Document Highlight" })
vim.keymap.set({ "i" }, "<C-p>", vim.lsp.buf.signature_help, { desc = "Signature Help" })

-- Exit terminal mode with ESC (single tap)
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- Markdown Tasks
-- vim.keymap.set("n", "<leader>[", "o- [ ] ", { desc = "New markdown task" })
-- vim.keymap.set("n", "<leader>]", function()
--   local line = vim.api.nvim_get_current_line()
--   local new_line = line:gsub("- %[ %]", "- [x]", 1)
--   vim.api.nvim_set_current_line(new_line)
-- end, { desc = "Mark task done" })
