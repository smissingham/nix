-- -- EXPERIMENTAL Type Checker & Full LSP
-- vim.lsp.config("ty", {
-- 	settings = {
-- 		ty = {
-- 			diagnosticmode = "workspaces",
-- 			disableLanguageServices = false,
-- 			experimental = {
-- 				rename = true,
-- 			},
-- 		},
-- 	},
-- })
-- vim.lsp.enable("ty"

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
