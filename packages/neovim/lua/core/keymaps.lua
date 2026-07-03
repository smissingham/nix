vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- General Globals
vim.keymap.set("n", "<esc><esc>", ":noh<CR>", { noremap = true, silent = true })

-- Text Processing

-- Buffer Navigation
vim.keymap.set("n", "<Tab>", "<cmd>bnext<CR>", {})
vim.keymap.set("n", "<S-Tab>", "<cmd>bprev<CR>", {})

-- Word / Line Navigation
vim.keymap.set({ "n", "v" }, "H", "^")
vim.keymap.set({ "n", "v" }, "L", "$")

-- Config Sourcing
vim.keymap.set("n", "<leader>xs", ":update<cr> :source<cr>", { desc = "Write & Source Buffer" })

-- Buffer Actions
vim.keymap.set("n", "<leader>O", function()
	local path = vim.fn.expand("%:p")

	if path == "" then
		vim.notify("Buffer has no file path", vim.log.levels.ERROR, {
			title = "Open Explorer",
		})
		return
	end

	require("lib.documents").open_path(vim.fs.dirname(path))
end, { desc = "Open Explorer" })

vim.keymap.set("n", "<leader>ae", "<cmd>DocumentExportPdfOpen<CR>", { desc = "Document export PDF" })
vim.keymap.set("n", "<leader>ao", "<cmd>DocumentExportPdfOpenDir<CR>", { desc = "Document export PDF and open dir" })

vim.keymap.set({ "n", "v" }, "<leader>bd", ":bd!<cr>", { desc = "Delete Buffer (Forced)" })
vim.keymap.set({ "n", "v" }, "<leader>bw", ":w!<cr>", { desc = "Write Buffer (Forced)" })
vim.keymap.set({ "n", "v" }, "<leader>be", ":e!<cr>", { desc = "Reset Buffer (Forced)" })

-- Tab Actions
vim.keymap.set("n", "<leader>tn", ":tabnew<cr>", { desc = "New Tab" })
vim.keymap.set("n", "<leader>tc", ":tabclose<cr>", { desc = "Close Tab" })
vim.keymap.set("n", "<leader><Tab>", ":tabnext<cr>", { desc = "Next Tab" })
vim.keymap.set("n", "<leader><S-Tab>", ":tabprevious<cr>", { desc = "Previous Tab" })

-- LSP
local function apply_lsp_quickfix()
	vim.lsp.buf.code_action({
		apply = true,
		context = {
			only = { "quickfix" },
			diagnostics = vim.diagnostic.get(0),
		},
	})
end

vim.keymap.set({ "n", "v" }, "<leader>lI", ":checkhealth vim.lsp<cr>", { desc = "Lsp Info" })
vim.keymap.set({ "n", "v" }, "<leader>lR", ":lsp restart<cr>", { desc = "Lsp Restart" })
vim.keymap.set({ "n", "v" }, "<leader>lS", ":lsp stop<cr>", { desc = "Lsp Stop" })

-- Coding with Symbols & Lsp
vim.keymap.set({ "n", "v" }, "<leader>grn", vim.lsp.buf.rename, { desc = "Rename" })
vim.keymap.set({ "n", "v" }, "<leader>grr", vim.lsp.buf.references, { desc = "References" })
vim.keymap.set({ "n", "v" }, "<leader>gri", vim.lsp.buf.implementation, { desc = "Go to Implementation" })
vim.keymap.set({ "n", "v" }, "<leader>gra", vim.lsp.buf.code_action, { desc = "Code Actions" })
vim.keymap.set({ "n", "v" }, "<leader>gq", apply_lsp_quickfix, { desc = "Apply Quick Fix" })
vim.keymap.set({ "n", "v" }, "<leader>gds", vim.lsp.buf.document_symbol, { desc = "Document Symbols" })
vim.keymap.set({ "n", "v" }, "<leader>gdh", vim.lsp.buf.document_highlight, { desc = "Document Highlight" })
vim.keymap.set({ "i" }, "<C-p>", vim.lsp.buf.signature_help, { desc = "Signature Help" })

-- Exit terminal mode with ESC (single tap)
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
