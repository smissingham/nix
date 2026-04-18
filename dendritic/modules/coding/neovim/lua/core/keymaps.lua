vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set("n", "<Esc><Esc>", "<cmd>nohlsearch<CR>", { silent = true })
vim.keymap.set("n", "<Tab>", "<cmd>bnext<CR>")
vim.keymap.set("n", "<S-Tab>", "<cmd>bprev<CR>")
vim.keymap.set({ "n", "v" }, "H", "^")
vim.keymap.set({ "n", "v" }, "L", "$")
vim.keymap.set({ "n", "v" }, "<leader>lI", ":checkhealth vim.lsp<cr>", { desc = "Lsp Info" })
vim.keymap.set({ "n", "v" }, "<leader>lR", ":LspRestart<cr>", { desc = "Lsp Restart" })
vim.keymap.set({ "n", "v" }, "<leader>lS", ":LspStop<cr>", { desc = "Lsp Stop" })
vim.keymap.set("n", "<leader>xr", "<cmd>ReloadConfig<CR>", { desc = "Reload config" })
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
