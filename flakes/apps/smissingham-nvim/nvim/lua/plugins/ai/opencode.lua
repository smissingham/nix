return {
	-- ##### OPENCODE ##### --
	{
		"NickvanDyke/opencode.nvim",
		dependencies = { "folke/snacks.nvim" },
		---@type opencode.Config
		opts = {
			-- Your configuration, if any
		},

    -- stylua: ignore
    config = function()
      vim.opt.autoread = true
      vim.keymap.set('n', '<leader>at', function() require('opencode').toggle() end, { desc = 'Toggle embedded' })
      vim.keymap.set('n', '<leader>aA', function() require('opencode').ask() end, { desc = 'Ask' })
      vim.keymap.set('n', '<leader>aa', function() require('opencode').ask('@cursor: ') end, { desc = 'Ask about this' })
      vim.keymap.set('v', '<leader>aa', function() require('opencode').ask('@selection: ') end, { desc = 'Ask about selection' })
      vim.keymap.set('n', '<leader>ae', function() require('opencode').prompt('Explain @cursor and its context') end, { desc = 'Explain this code' })
      vim.keymap.set('n', '<leader>a+', function() require('opencode').prompt('@buffer', { append = true }) end, { desc = 'Add buffer to prompt' })
      vim.keymap.set('v', '<leader>a+', function() require('opencode').prompt('@selection', { append = true }) end, { desc = 'Add selection to prompt' })
      vim.keymap.set('n', '<leader>an', function() require('opencode').command('session_new') end, { desc = 'New session' })
      vim.keymap.set('n', '<S-C-u>',    function() require('opencode').command('messages_half_page_up') end, { desc = 'Messages half page up' })
      vim.keymap.set('n', '<S-C-d>',    function() require('opencode').command('messages_half_page_down') end, { desc = 'Messages half page down' })
      vim.keymap.set({ 'n', 'v' }, '<leader>as', function() require('opencode').select() end, { desc = 'Select prompt' })
    end,
	},
}
