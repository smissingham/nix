vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"

require("config.lazy")

vim.opt.shiftwidth = 4
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.undofile = true -- Persistent undo/redo tree save to file in ~/.local...

vim.keymap.set("n", "<leader>x", "<cmd>.lua<CR>")

vim.cmd("ShowkeysToggle");
