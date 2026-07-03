local M = {}

function M.notify_error(title, message)
	vim.notify(message, vim.log.levels.ERROR, {
		title = title,
	})
end

function M.executable_or_notify(title, bin)
	if vim.fn.executable(bin) == 1 then
		return true
	end

	M.notify_error(title, "Missing executable: " .. bin)
	return false
end

function M.current_pdf_paths(title)
	local input = vim.fn.expand("%:p")

	if input == "" then
		M.notify_error(title, "Buffer has no file path")
		return nil
	end

	return {
		input = input,
		output = vim.fn.expand("%:p:r") .. ".pdf",
	}
end

function M.runtime_file(path, title)
	local files = vim.api.nvim_get_runtime_file(path, false)

	if files[1] then
		return files[1]
	end

	local source = debug.getinfo(1, "S").source:sub(2)
	local config_path = vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(source)))
	local local_file = vim.fs.joinpath(config_path, path)

	if vim.fn.filereadable(local_file) == 1 then
		return local_file
	end

	M.notify_error(title, "Missing runtime file: " .. path)
	return nil
end

function M.open_path(path)
	if vim.fn.has("mac") == 1 then
		vim.system({ "open", path })
		return
	end

	if vim.fn.has("win32") == 1 then
		vim.system({ "cmd", "/c", "start", "", path })
		return
	end

	if vim.fn.isdirectory(path) == 1 then
		for _, opener in ipairs({ "nautilus", "dolphin", "thunar", "nemo", "pcmanfm" }) do
			if vim.fn.executable(opener) == 1 then
				vim.system({ opener, path })
				return
			end
		end
	end

	vim.system({ "xdg-open", path })
end

function M.finish_export(title, output, opts)
	opts = opts or {}

	vim.notify("Wrote " .. output, vim.log.levels.INFO, {
		title = title,
	})

	if not opts.open and not opts.open_dir then
		return
	end

	local open_target = opts.open_dir and vim.fs.dirname(output) or output
	M.open_path(open_target)
end

function M.export_markdown_pdf(opts)
	opts = opts or {}

	local title = "Markdown PDF export"

	if vim.bo.filetype ~= "markdown" then
		M.notify_error(title, "Current buffer is not markdown")
		return
	end

	if not M.executable_or_notify(title, "pandoc") then
		return
	end

	if not M.executable_or_notify(title, "typst") then
		return
	end

	local callout_filter = M.runtime_file("lua/lib/markdown.lua", title)

	if not callout_filter then
		return
	end

	if vim.fn.filereadable(callout_filter) ~= 1 then
		M.notify_error(title, "Missing Pandoc callout filter: " .. callout_filter)
		return
	end

	local paths = M.current_pdf_paths(title)

	if not paths then
		return
	end

	local metadata_file = vim.fn.tempname() .. ".yaml"

	vim.cmd.write()

	if vim.fn.writefile({ "margin:", "  x: 1.5cm", "  y: 1.5cm" }, metadata_file) ~= 0 then
		M.notify_error(title, "Could not write Pandoc metadata file")
		return
	end

	vim.system({
		"pandoc",
		paths.input,
		"--metadata-file",
		metadata_file,
		"--lua-filter",
		callout_filter,

		"--from",
		"markdown+wikilinks_title_after_pipe+mark+task_lists+pipe_tables+strikeout+fenced_divs",

		"--to",
		"typst",
		"--pdf-engine",
		"typst",
		"--standalone",

		"--variable",
		"mainfont=Noto Sans",
		"--variable",
		"monofont=JetBrainsMono NF",

		"--output",
		paths.output,
	}, { text = true }, function(result)
		vim.schedule(function()
			vim.fn.delete(metadata_file)

			if result.code ~= 0 then
				M.notify_error(title, result.stderr ~= "" and result.stderr or "Pandoc failed")
				return
			end

			M.finish_export(title, paths.output, opts)
		end)
	end)
end

function M.export_typst_pdf(opts)
	opts = opts or {}

	local title = "Typst PDF export"

	if vim.bo.filetype ~= "typst" then
		M.notify_error(title, "Current buffer is not typst")
		return
	end

	if not M.executable_or_notify(title, "typst") then
		return
	end

	local paths = M.current_pdf_paths(title)

	if not paths then
		return
	end

	vim.cmd.write()

	vim.system({ "typst", "compile", paths.input, paths.output }, { text = true }, function(result)
		vim.schedule(function()
			if result.code ~= 0 then
				M.notify_error(title, result.stderr ~= "" and result.stderr or "Typst export failed")
				return
			end

			M.finish_export(title, paths.output, opts)
		end)
	end)
end

function M.export_pdf(opts)
	local exporters = {
		markdown = M.export_markdown_pdf,
		typst = M.export_typst_pdf,
	}
	local export = exporters[vim.bo.filetype]

	if not export then
		M.notify_error("Document PDF export", "Unsupported filetype: " .. vim.bo.filetype)
		return
	end

	export(opts)
end

local function create_commands(commands)
	for name, action in pairs(commands) do
		vim.api.nvim_create_user_command(name, action, { force = true })
	end
end

local function set_preview_keymap(filetype, command, desc)
	local function set_keymap(bufnr)
		vim.keymap.set("n", "<leader>ap", command, {
			buffer = bufnr,
			desc = desc,
		})
	end

	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup(filetype .. "_preview_keymap", { clear = true }),
		pattern = filetype,
		callback = function(args)
			set_keymap(args.buf)
		end,
	})

	if vim.bo.filetype == filetype then
		set_keymap(0)
	end
end

function M.setup()
	create_commands({
		DocumentExportPdf = M.export_pdf,
		DocumentExportPdfOpen = function()
			M.export_pdf({ open = true })
		end,
		DocumentExportPdfOpenDir = function()
			M.export_pdf({ open_dir = true })
		end,
	})
end

function M.setup_markdown_preview()
	set_preview_keymap("markdown", "<cmd>MarkdownPreviewToggle<CR>", "Markdown preview toggle")
end

function M.setup_typst_preview()
	set_preview_keymap("typst", "<cmd>TypstPreviewToggle<CR>", "Typst preview toggle")
end

return M
