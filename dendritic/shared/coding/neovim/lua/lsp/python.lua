-- Linting, formatting and imports
vim.lsp.config("ruff", {
  filetypes = { "python" },
  cmd = { "ruff", "server" },
  root_markers = {
    "uv.toml",
    "pyproject.toml",
    "requirements.txt",
    ".git",
  },
  init_options = {
    settings = {
      format = {
        enable = true,
      },
      organizeImports = true,
    },
  },
})
vim.lsp.enable("ruff")

-- Optional: Only required if you need to update the language server settings
vim.lsp.config("ty", {
  filetypes = { "python" },
  cmd = { "ty", "server" },
  root_markers = {
    "ty.toml",
    "pyproject.toml",
    "requirements.txt",
    ".git",
  },
  settings = {
    ty = {
      -- ty language server settings go here
    },
  },
})
vim.lsp.enable("ty")

-- Type checking
-- vim.lsp.config("basedpyright", {
--   filetypes = { "python" },
--   cmd = { "basedpyright-langserver", "--stdio" },
--   root_markers = {
--     "uv.toml",
--     "pyproject.toml",
--     "requirements.txt",
--     ".git",
--   },
--   settings = {
--     basedpyright = {
--       analysis = {
--         autoSearchPaths = true,
--         useLibraryCodeForTypes = true,
--         diagnosticMode = "workspace",
--         typeCheckingMode = "recommended",
--         autoFormatStrings = true,
--       },
--     },
--   },
-- })
-- vim.lsp.enable("basedpyright")
