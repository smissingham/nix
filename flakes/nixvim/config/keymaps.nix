{
  keymaps = [
    # ----- FILE OPERATIONS ----- #
    {
      mode = "n";
      key = "<leader>s";
      action = ":w<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Save (Write) File";
      };
    }

    {
      mode = "n";
      key = "<leader>q";
      action = ":q<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Quit";
      };
    }

    {
      mode = "n";
      key = "<leader>re";
      action = ":e!<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Abandon active file changes";
      };

    }

    # ----- TELESCOPE ----- #
    {
      mode = "n";
      key = "<leader>ff";
      action = "<cmd>Telescope find_files<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Find files";
      };
    }
    {
      mode = "n";
      key = "<leader>fd";
      action = "<cmd>Telescope file_browser<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "File browser";
      };
    }
    {
      mode = "n";
      key = "<leader>fg";
      action = "<cmd>Telescope live_grep<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Live grep search";
      };
    }

    # ----- TAB MANAGEMENT ----- #
    {
      mode = "n";
      key = "<leader>tn";
      action = ":tabnew<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "New tab";
      };
    }
    {
      mode = "n";
      key = "<leader>tc";
      action = ":tabclose<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Close tab";
      };
    }

    # ----- NEOTREE ----- #
    {
      mode = "n";
      key = "\\ft";
      action = ":Neotree<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Toggle Neotree";
      };
    }
    {
      mode = "n";
      key = "\\ftt";
      action = ":Neotree toggle<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Toggle Neotree";
      };
    }
  ];
}
