local function lsp_clients()
	local bufnr = vim.api.nvim_get_current_buf()
	local clients = vim.lsp.get_clients({ bufnr = bufnr })
	if #clients == 0 then
		return ""
	end
	local names = {}
	for _, client in ipairs(clients) do
		names[#names + 1] = client.name
	end
	table.sort(names)
	return table.concat(names, ", ")
end
local function lsp_progress()
	return vim.lsp.status()
end
return {
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				sections = {
					lualine_c = {
						{
							"filename",
							path = 1,
						},
					},
					lualine_x = {
						{ require("opencode").statusline },
						"encoding",
						"fileformat",
						"filetype",
						{
							lsp_clients,
							cond = function()
								return lsp_clients() ~= ""
							end,
							color = { fg = "#7aa2f7" },
						},
						{
							lsp_progress,
							cond = function()
								return lsp_progress() ~= ""
							end,
							color = { fg = "#ff9e64" },
						},
					},
				},
			})
			vim.api.nvim_create_autocmd("LspProgress", {
				callback = function()
					require("lualine").refresh()
				end,
			})
		end,
	},
}
