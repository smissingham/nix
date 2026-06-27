local config_path = vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2))))
local lua_path = vim.fs.joinpath(config_path, "lua")

package.path = table.concat({
	vim.fs.joinpath(lua_path, "?.lua"),
	vim.fs.joinpath(lua_path, "?", "init.lua"),
	package.path,
}, ";")

return {
	config_path = config_path,
	require_modules = function(directory)
		local modules = {}
		local path = vim.fs.joinpath(config_path, "lua", directory)

		if not (vim.uv or vim.loop).fs_stat(path) then
			return
		end

		for name, entry_type in vim.fs.dir(path) do
			if entry_type == "file" and name:sub(-4) == ".lua" then
				modules[#modules + 1] = vim.fs.joinpath(path, name)
			end
		end

		table.sort(modules)

		for _, module_path in ipairs(modules) do
			dofile(module_path)
		end
	end,
}
