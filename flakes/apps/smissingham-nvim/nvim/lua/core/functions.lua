-- Reusable utility functions

local M = {}

--- Check if .nvim.lua exists and contains specific pattern
--- @param pattern string Pattern to match (e.g., "vim%.lsp")
--- @return boolean
function M.has_nvim_lua_with_pattern(pattern)
  local cwd = vim.fn.getcwd()
  local nvim_lua = cwd .. "/.nvim.lua"
  
  if vim.fn.filereadable(nvim_lua) ~= 1 then
    return false
  end
  
  local content = vim.fn.readfile(nvim_lua)
  for _, line in ipairs(content) do
    if line:match(pattern) then
      return true
    end
  end
  
  return false
end

return M
