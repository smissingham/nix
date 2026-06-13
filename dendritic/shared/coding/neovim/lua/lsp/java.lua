vim.lsp.config("jdtls", {
  filetypes = { "java" },
  cmd = { "jdtls" },
  root_markers = {
    "pom.xml",
    "build.gradle",
    ".git",
  },
  settings = {
    java = {
      autobuild = {
        enabled = false
      },
      format = {
        enabled = false
      },
      import = {
        maven = {
          enabled = false
        }
      },
      configuration = {
        updateBuildConfiguration = "automatic"
      }
    }
  }
})
vim.lsp.enable("jdtls")
