{
  keymaps = [
    # ----- FILE OPERATIONS ----- #
    {
      mode = "n";
      key = "<leader>s";
      action = "<cmd>w<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Save (Write) File";
      };
    }

    {
      mode = "n";
      key = "<leader>q";
      action = "<cmd>q<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Quit";
      };
    }

    {
      mode = "n";
      key = "<leader>re";
      action = "<cmd>e!<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Abandon active file changes";
      };

    }

    # ----- TELESCOPE ----- #
    {
      mode = "n";
      key = "<leader>te";
      action = "<cmd>Telescope<CR>";
      options = {
        silent = true;
        noremap = true;
      };
    }
    {
      mode = "n";
      key = "<leader>ff";
      action = "<cmd>Telescope find_files<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Find Files";
      };
    }
    {
      mode = "n";
      key = "<leader>fb";
      action = "<cmd>Telescope buffers<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Switch between open buffers";
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
      action = "<cmd>tabnew<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "New tab";
      };
    }
    {
      mode = "n";
      key = "<leader>tc";
      action = "<cmd>tabclose<CR>";
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
      action = "<cmd>Neotree<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Toggle Neotree";
      };
    }
    {
      mode = "n";
      key = "\\ftt";
      action = "<cmd>Neotree toggle<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Toggle Neotree";
      };
    }
  ];
}
