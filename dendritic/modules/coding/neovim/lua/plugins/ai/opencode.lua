return {
  -- ##### OPENCODE ##### --
  -- {
  -- 	"NickvanDyke/opencode.nvim",
  -- 	dependencies = { "folke/snacks.nvim" },
  -- 	---@type opencode.Config
  -- 	opts = {
  -- 		-- Your configuration, if any
  -- 	},
  --
  --    -- stylua: ignore
  --    config = function()
  --      vim.opt.autoread = true
  --      vim.keymap.set('n', '<leader>at', function() require('opencode').toggle() end, { desc = 'Toggle embedded' })
  --      vim.keymap.set('n', '<leader>aA', function() require('opencode').ask() end, { desc = 'Ask' })
  --      vim.keymap.set('n', '<leader>aa', function() require('opencode').ask('@cursor: ', {}) end, { desc = 'Ask about this' })
  --      vim.keymap.set('v', '<leader>aa', function() require('opencode').ask('@selection: ', {}) end, { desc = 'Ask about selection' })
  --      vim.keymap.set('n', '<leader>ae', function() require('opencode').prompt('Explain @cursor and its context') end, { desc = 'Explain this code' })
  --      vim.keymap.set('n', '<leader>a+', function() require('opencode').prompt('@buffer', { append = true }) end, { desc = 'Add buffer to prompt' })
  --      vim.keymap.set('v', '<leader>a+', function() require('opencode').prompt('@selection', { append = true }) end, { desc = 'Add selection to prompt' })
  --      vim.keymap.set('n', '<leader>an', function() require('opencode').command('session_new') end, { desc = 'New session' })
  --      vim.keymap.set('n', '<S-C-u>',    function() require('opencode').command('messages_half_page_up') end, { desc = 'Messages half page up' })
  --      vim.keymap.set('n', '<S-C-d>',    function() require('opencode').command('messages_half_page_down') end, { desc = 'Messages half page down' })
  --      vim.keymap.set({ 'n', 'v' }, '<leader>as', function() require('opencode').select() end, { desc = 'Select prompt' })
  --    end,
  -- },
  {
    "NickvanDyke/opencode.nvim",
    dependencies = {
      -- Recommended for `ask()` and `select()`.
      -- Required for `snacks` provider.
      ---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
      { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
    },
    config = function()
      ---@type opencode.Opts
      vim.g.opencode_opts = {
        -- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition" on the type or field.
      }

      -- Required for `opts.events.reload`.
      vim.o.autoread = true

      -- Recommended/example keymaps.
      vim.keymap.set({ "n", "x" }, "<C-a>", function() require("opencode").ask("@this: ", { submit = true }) end,
        { desc = "Ask opencode…" })
      vim.keymap.set({ "n", "x" }, "<C-x>", function() require("opencode").select() end,
        { desc = "Execute opencode action…" })
      vim.keymap.set({ "n", "t" }, "<C-.>", function() require("opencode").toggle() end, { desc = "Toggle opencode" })

      vim.keymap.set({ "n", "x" }, "go", function() return require("opencode").operator("@this ") end,
        { desc = "Add range to opencode", expr = true })
      vim.keymap.set("n", "goo", function() return require("opencode").operator("@this ") .. "_" end,
        { desc = "Add line to opencode", expr = true })

      vim.keymap.set("n", "<S-C-u>", function() require("opencode").command("session.half.page.up") end,
        { desc = "Scroll opencode up" })
      vim.keymap.set("n", "<S-C-d>", function() require("opencode").command("session.half.page.down") end,
        { desc = "Scroll opencode down" })

      -- You may want these if you stick with the opinionated "<C-a>" and "<C-x>" above — otherwise consider "<leader>o…".
      vim.keymap.set("n", "+", "<C-a>", { desc = "Increment under cursor", noremap = true })
      vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement under cursor", noremap = true })
    end,
  }
}
