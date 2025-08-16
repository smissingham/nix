return {
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      --{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release' }
    },
    config = function()
      local telescope = require('telescope')
      telescope.setup {
        --config here
      }
      telescope.load_extension('fzf')

      vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { desc = "Find Files" })
      vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<CR>', { desc = "Live Grep" })
      vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<CR>', { desc = "Buffers" })
      vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<CR>', { desc = "Help Tags" })
    end
  },
}
