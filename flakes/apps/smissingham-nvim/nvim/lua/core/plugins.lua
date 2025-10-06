-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Helper function to recursively import plugin directories
local function get_plugin_imports()
	local imports = { { import = "plugins" } }

	-- Get all subdirectories in plugins/
	local plugins_path = vim.fn.stdpath("config") .. "/lua/plugins"
	local handle = vim.loop.fs_scandir(plugins_path)

	if handle then
		while true do
			local name, type = vim.loop.fs_scandir_next(handle)
			if not name then
				break
			end

			if type == "directory" then
				table.insert(imports, { import = "plugins." .. name })
			end
		end
	end

	return imports
end

-- Setup lazy.nvim
require("lazy").setup({
	spec = get_plugin_imports(),
	checker = { enabled = true },
})
