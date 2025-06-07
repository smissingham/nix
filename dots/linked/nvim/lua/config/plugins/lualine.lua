return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup({
        sections = {
          lualine_x = {
            { require 'minuet.lualine', },
            'encoding',
            'fileformat',
            'filetype'
          }
        }
      })
    end
  }
}
