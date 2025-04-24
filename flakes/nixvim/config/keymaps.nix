{
  keymaps = [
    # ----- FILE OPERATIONS ----- #
    {
      mode = "n";
      key = "<leader>w";
      action = ":w<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Write file";
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
  ];
}
