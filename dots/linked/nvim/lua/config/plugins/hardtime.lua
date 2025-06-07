return {
  {
    "m4xshen/hardtime.nvim",
    lazy = false,
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      max_count = 10,
      disable_mouse = false,
      disabled_keys = {
        ["<Left>"] = false,
        ["<Right>"] = false,
      }
    },
  },
}
