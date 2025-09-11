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

require_dir("config/lsp")
require("config.keymaps")
require("config.options")
require("config.commands")
require("config.plugins")

vim.cmd.colorscheme("tokyonight")
