return {
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
    -- stylua: ignore
    keys = {
      { "]t",         function() require("todo-comments").jump_next() end,             desc = "Next todo comment" },
      { "[t",         function() require("todo-comments").jump_prev() end,             desc = "Previous todo comment" },
      { "<leader>ft", function() require("snacks").picker.todo_comments() end,         desc = "Search ToDo's" },
      { "<leader>lt", "<cmd>Trouble close<cr><cmd>Trouble todo toggle focus=true<cr>", desc = "Todo & Warn List (Trouble)" },
      { "<leader>lT", "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>",                  desc = "Todo/Fix/Fixme (Trouble)" },
    }
  },
  {
    "folke/trouble.nvim",
    cmd = { "Trouble" },
    opts = {
      win = {
        size = 0.33,
        --relative = "win",
        --position = "right",
      },
      keys = {
        ["<cr>"] = "jump_close",
      },
    },
    keys = {
      { "<leader>ld", "<cmd>Trouble close<cr><cmd>Trouble diagnostics toggle focus=true<cr>",              desc = "Diagnostics (Trouble)" },
      { "<leader>lb", "<cmd>Trouble close<cr><cmd>Trouble diagnostics toggle filter.buf=0 focus=true<cr>", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>ls", "<cmd>Trouble close<cr><cmd>Trouble symbols toggle focus=true<cr>",                  desc = "Symbols (Trouble)" },
      { "<leader>lr", "<cmd>Trouble close<cr><cmd>Trouble lsp toggle focus=true<cr>",                      desc = "LSP references/definitions/... (Trouble)" },
      { "<leader>ll", "<cmd>Trouble close<cr><cmd>Trouble loclist toggle focus=true<cr>",                  desc = "Location List (Trouble)" },
      { "<leader>lq", "<cmd>Trouble close<cr><cmd>Trouble qflist toggle focus=true<cr>",                   desc = "Quickfix List (Trouble)" },
      {
        "[q",
        function()
          if require("trouble").is_open() then
            require("trouble").prev({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cprev)
            if not ok then
              vim.notify(err, vim.log.levels.ERROR)
            end
          end
        end,
        desc = "Previous Trouble/Quickfix Item",
      },
      {
        "]q",
        function()
          if require("trouble").is_open() then
            require("trouble").next({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cnext)
            if not ok then
              vim.notify(err, vim.log.levels.ERROR)
            end
          end
        end,
        desc = "Next Trouble/Quickfix Item",
      },
    },
  },
}
