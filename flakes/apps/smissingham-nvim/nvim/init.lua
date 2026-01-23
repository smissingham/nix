local function require_dir(dir)
	local path = vim.fn.stdpath("config") .. "/lua/" .. dir
	local files = vim.fn.readdir(path)
	for _, file in ipairs(files) do
		if file:match("%.lua$") then
			local module = dir .. "." .. file:gsub("%.lua$", "")
			require(module)
		end
	end
end

require_dir("lsp")
require("core.keymaps")
require("core.options")
require("core.commands")
require("core.plugins")

-- Load project-specific .nvim.lua if available
local function load_project_config()
  local config_file = vim.fn.getcwd() .. "/.nvim.lua"
  if vim.fn.filereadable(config_file) == 1 then
    dofile(config_file)
  end
end

-- Auto-load project config on directory change
vim.api.nvim_create_autocmd({ "DirChanged", "VimEnter" }, {
  callback = load_project_config,
})

-- Load immediately
load_project_config()
