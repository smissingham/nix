local function lsp_modules()
  local modules = {}
  local source = debug.getinfo(1, "S").source:sub(2)
  local lsp_path = vim.fs.joinpath(vim.fs.dirname(source), "..", "lsp")

  for name, entry_type in vim.fs.dir(lsp_path) do
    if entry_type == "file" and name:sub(-4) == ".lua" then
      modules[#modules + 1] = "lsp." .. name:gsub("%.lua$", "")
    end
  end

  table.sort(modules)

  return modules
end

for _, module in ipairs(lsp_modules()) do
  require(module)
end
