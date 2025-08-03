-- General Globals
vim.keymap.set("n", "<esc><esc>", ":noh<CR>", { noremap = true, silent = true })

-- Buffer Navigation
vim.keymap.set("n", "<Tab>", "<cmd>bnext<CR>", {})
vim.keymap.set("n", "<S-Tab>", "<cmd>bprev<CR>", {})

-- Word / Line Navigation
vim.keymap.set({ "n", "v" }, "H", "^")
vim.keymap.set({ "n", "v" }, "L", "$")

-- Remap Ctrl Up/Down Keys
vim.keymap.set({ "n", "v" }, "<C-u>", "<C-d>", { noremap = true, desc = "" })
vim.keymap.set({ "n", "v" }, "<C-i>", "<C-u>", { noremap = true, desc = "" })
