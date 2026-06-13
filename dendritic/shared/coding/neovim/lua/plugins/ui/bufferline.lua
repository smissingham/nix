return {
  {
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      require("bufferline").setup({
        options = {
          --mode = 'tabs',
          diagnostics = 'nvim_lsp',
          middle_mouse_command = 'bdelete! %d',
          offsets = {
            {
              filetype = 'snacks_layout_box',
              text = '󰙅  File Explorer',
              separator = true,
            },
          },
        },
      })
    end
  }
}
