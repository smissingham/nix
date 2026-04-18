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

-- Optional: Only required if you need to update the language server settings
vim.lsp.config('ty', {
  settings = {
    ty = {
      -- ty language server settings go here
    }
  },
  root_markers = {
    "ty.toml",
    "pyproject.toml",
    "requirements.txt",
    ".git",
  },
})
vim.lsp.enable('ty')

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
        -- inlayHints = {
        --   variableTypes = true,
        --   functionReturnTypes = true,
        --   callArgumentNames = false,
        -- },
        autoFormatStrings = true,
      },
    },
  },
})
--vim.lsp.enable("basedpyright")
