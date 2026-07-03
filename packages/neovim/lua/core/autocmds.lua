vim.api.nvim_create_autocmd("FileType", {
	pattern = { "gitcommit", "markdown", "text" },
	callback = function()
		vim.opt_local.spell = true
	end,
})

local function tmux_window_name()
	local cwd = vim.uv.cwd()

	if not cwd or vim.env.TMUX == nil then
		return
	end

	local git_root = vim.fn.systemlist({ "git", "-C", cwd, "rev-parse", "--show-toplevel" })[1]
	local path = vim.v.shell_error == 0 and git_root or cwd
	local name = vim.fs.basename(path)

	if not name or name == "" then
		return
	end

	vim.fn.system({ "tmux", "rename-window", name })
end

vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
	callback = tmux_window_name,
})
