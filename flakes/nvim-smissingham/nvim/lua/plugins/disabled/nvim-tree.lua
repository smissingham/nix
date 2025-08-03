return {
	{
    "nvim-tree/nvim-tree.lua",
    version = "*",
    --lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup{
	  actions = {
	      open_file = {
		  --quit_on_open = true,
	      },
	  },
	  git = {
	      enable = false,
	  },
	  update_focused_file = {
	      enable = true,
	      update_cwd = true
	  },
	  view = {
	      width = 40
	  },
      }
      --vim.g.loaded_netrw = 1
      --vim.g.loadednetrwPlugin = 1
      vim.keymap.set('n', '<leader>tf', '<cmd>NvimTreeFocus<CR>', { desc = "Tree Focus" })
      vim.keymap.set('n', '<leader>tt', '<cmd>NvimTreeToggle<CR>', { desc = "Tree Toggle" })
      vim.keymap.set('n', '<leader>tc', '<cmd>NvimTreeCollapse<CR>', { desc = "Tree Collapse" })
      vim.keymap.set('n', '<leader>tq', '<cmd>NvimTreeClose<CR>', { desc = "Tree Quit" })
    end,
  }
}
