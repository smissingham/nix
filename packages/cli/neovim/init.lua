local config_path = vim.fs.dirname(debug.getinfo(1, "S").source:sub(2))

vim.opt.runtimepath:prepend(config_path)

local lib = require("core.lib")

require("core.options")
require("core.keymaps")
require("core.autocmds")
require("lib.documents").setup()
require("core.plugins")

lib.require_modules("lsp")
lib.require_modules("actions")
