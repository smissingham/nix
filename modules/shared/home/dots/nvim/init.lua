vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"

require("config.lazy")

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.undofile = true -- Persistent undo/redo tree save to file in ~/.local...

vim.keymap.set("n", "<leader>x", "<cmd>.lua<CR>")

vim.cmd("ShowkeysToggle");
