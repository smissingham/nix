vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"

require("config.lazy")

vim.opt.tabstop = 2               -- Number of spaces a tab counts for
vim.opt.shiftwidth = 2            -- Number of spaces to use for autoindent
vim.opt.expandtab = true          -- Use spaces instead of tabs
vim.opt.smartindent = true        -- Smart autoindenting
vim.opt.number = true             -- Show line numbers
vim.opt.relativenumber = true     -- Show relative line numbers
vim.opt.colorcolumn = '80'        -- Show vertical line guide at char 80
vim.opt.undofile = true           -- Persistent undo/redo tree save to file in ~/.local...
vim.opt.wrap = false              -- Disable word wrapping
vim.opt.cursorline = true         -- Highlight the current line
vim.opt.wrap = false              -- Disable word wrapping
vim.opt.cursorline = true         -- Highlight the current line
vim.opt.clipboard = 'unnamedplus' -- Allow sharing the system clipboard
vim.opt.ignorecase = true         -- Make search case-insensitive by default
vim.opt.smartcase = true          -- Make search case-sensitive when using uppercase letters


vim.keymap.set('n', '<esc><esc>', ':noh<CR>', { noremap = true, silent = true })
vim.keymap.set("n", "<leader>x", "<cmd>.lua<CR>")


vim.keymap.set('n', '<Up>', '<Nop>', { noremap = true, silent = true })
vim.keymap.set('n', '<Down>', '<Nop>', { noremap = true, silent = true })
vim.keymap.set('n', '<Left>', '<Nop>', { noremap = true, silent = true })
vim.keymap.set('n', '<Right>', '<Nop>', { noremap = true, silent = true })

vim.keymap.set('n', '<Tab>', '<cmd>bnext<CR>', {})
vim.keymap.set('n', '<S-Tab>', '<cmd>bprev<CR>', {})

vim.cmd("ShowkeysToggle");
