vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"

require("config.keymaps")
require("config.options")
require("config.plugins") -- Lazy nvim

vim.cmd.colorscheme "catppuccin"
