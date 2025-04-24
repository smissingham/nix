{ pkgs, ... }:
{
  # Import all configuration modules
  imports = [
    ./keymaps.nix
    ./plugins/avante.nix
    ./plugins/bufferline.nix
    ./plugins/treesitter.nix
  ];

  # Theme configuration
  colorschemes.catppuccin = {
    enable = true;
    settings.flavour = "mocha";
  };

  # Editor options
  # Global vim options
  globalOpts = {
    autoindent = true;
    backspace = "indent,eol,start";
    expandtab = true;
    hidden = true;
    hlsearch = true;
    ignorecase = true;
    incsearch = true;
    mouse = "a";
    number = true;
    relativenumber = true;
    smartcase = true;
    smartindent = true;
    sts = 2;
    sw = 2;
  };

  # Local buffer options
  localOpts = {
    number = true;
    relativenumber = true;
  };

  # Window options
  opts = {
    number = true; # Show line numbers
    relativenumber = true; # Show relative line numbers
    shiftwidth = 2; # Tab width should be 2
    termguicolors = true; # Enable true color support
  };

  # Plugin configurations
  plugins = {
    # Completion plugins
    cmp = {
      enable = true;
      autoEnableSources = true;
      settings = {

        completion.autoComplete = true;
        sources = [
          { name = "nvim_lsp"; }
          { name = "buffer"; }
          { name = "path"; }
        ];
      };
    };

    # Code formatting
    conform-nvim = {
      enable = true;
      settings = {
        notify_on_error = true;
        format_on_save = {
          enable = true;
          lspFallback = true;
        };
        formatters_by_ft = {
          nix = [ "nixfmt" ];
        };
      };
    };

    # Language server protocol
    lsp = {
      enable = true;
      servers = {
        nixd.enable = true;
        nixd.autostart = true;
      };
    };

    # Lazy loading
    lz-n = {
      enable = true;
      autoLoad = true;
    };

    # Status line
    lualine = {
      enable = true;
    };

    # Fuzzy finder
    telescope = {
      enable = true;
      extensions = {
        file-browser.enable = true;
        fzf-native.enable = true;
      };
    };
  };
}
