-- Default Python LSP configuration
-- Skip if .nvim.lua exists and contains LSP config

local functions = require("core.functions")

if not functions.has_nvim_lua_with_pattern("vim%.lsp") then
  -- Linting, formatting and imports
  vim.lsp.config("ruff", {
    init_options = {
      settings = {
        format = {
          enable = true,
        },
        organizeImports = true,
      },
    },
    root_markers = {
      "uv.toml",
      "pyproject.toml",
      "requirements.txt",
      ".git",
    },
  })
  vim.lsp.enable("ruff")

  -- Type checking
  vim.lsp.config("basedpyright", {
    root_markers = {
      "uv.toml",
      "pyproject.toml",
      "requirements.txt",
      ".git",
    },
    settings = {
      basedpyright = {
        analysis = {
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
          diagnosticMode = "workspace",
          typeCheckingMode = "recommended",
          inlayHints = {
            variableTypes = true,
            functionReturnTypes = true,
            callArgumentNames = false,
          },
          autoFormatStrings = true,
        },
      },
    },
  })
  vim.lsp.enable("basedpyright")
end
