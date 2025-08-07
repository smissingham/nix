-- Reload All Nvim Config
vim.api.nvim_create_user_command("ReloadConfig", function()
	for name, _ in pairs(package.loaded) do
		if name:match("^config") or name:match("^plugins") or name:match("^user") then
			package.loaded[name] = nil
		end
	end
	dofile(vim.env.MYVIMRC)
	print(string.format("Config reloaded from %s", vim.env.MYVIMRC))
end, {})
