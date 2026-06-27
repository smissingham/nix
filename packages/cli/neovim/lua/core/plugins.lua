local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

local function current_file_dir()
  local source = debug.getinfo(1, "S").source:sub(2)

  return vim.fs.dirname(source)
end

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })

  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
    }, true, {})
    error("lazy.nvim bootstrap failed")
  end
end

vim.opt.rtp:prepend(lazypath)

local function plugin_imports()
  local imports = {}
  local plugins_path = vim.fs.joinpath(current_file_dir(), "..", "plugins")

  local function collect_plugin_specs(path)
    local entries = {}

    for name, entry_type in vim.fs.dir(path) do
      entries[#entries + 1] = { name = name, entry_type = entry_type }
    end

    table.sort(entries, function(left, right)
      return left.name < right.name
    end)

    for _, entry in ipairs(entries) do
      local entry_path = vim.fs.joinpath(path, entry.name)

      if entry.entry_type == "directory" then
        collect_plugin_specs(entry_path)
      elseif entry.entry_type == "file" and entry.name:sub(-4) == ".lua" then
        local chunk, err = loadfile(entry_path)

        if not chunk then
          error(err)
        end

        local spec = chunk()

        if spec ~= nil then
          vim.list_extend(imports, spec)
        end
      end
    end
  end

  collect_plugin_specs(plugins_path)

  return imports
end

require("lazy").setup({
  spec = plugin_imports(),
  install = { colorscheme = { "habamax" } },
  checker = { enabled = false },
  rocks = { enabled = false }
})
