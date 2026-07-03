local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.wrap = false
opt.cursorline = true
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true
opt.clipboard = "unnamedplus"
opt.spelllang = "en_au"
opt.title = true
opt.titlestring = "%{v:lua.SmWindowTitle()}"

function _G.SmWindowTitle()
	local buffer_name = vim.api.nvim_buf_get_name(0)
	local path = buffer_name ~= "" and buffer_name or vim.uv.cwd()

	if not path then
		return "SN"
	end

	local git_root = vim.fs.root(path, ".git")
	local repo_name = git_root and vim.fs.basename(git_root) or nil
	local file_name = buffer_name ~= "" and vim.fs.basename(buffer_name) or nil
	local parts = { "SN" }

	if repo_name and repo_name ~= "" then
		parts[#parts + 1] = repo_name
	end

	if file_name and file_name ~= "" then
		parts[#parts + 1] = file_name
	end

	return table.concat(parts, " | ")
end

--vim.o.shell = "bash"
