{
  pkgs,
  mainUser,
  ...
}:
{
  home-manager.users.${mainUser.username} =
    {
      shellHelpers,
      ...
    }:
    {
      home.packages = with pkgs; [
        # System utilities
        pciutils
        usbutils
        findutils

        # Development tools
        dig
        gnupg
        git
        just
        stow
        tmux

        # TUI's
        btop
        lazygit

        # CLI productivity
        bat
        fd
        ripgrep
        ripgrep-all
        eza
        fzf
        tldr
        xclip
      ];

      programs.git = {
        enable = true;
        userName = mainUser.name;
        userEmail = mainUser.email;
        delta = {
          enable = true;
          options = {
            navigate = true;
            line-numbers = true;
            dark = true;
          };
        };
      };

      # Automatic environment loading for project directories
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
      };

      # Smart directory navigation that learns your habits
      programs.zoxide = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
      };

      # Customizable cross-shell prompt
      programs.starship = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        enableNushellIntegration = true;
      };

      # Sync and search shell history across shells and machines
      programs.atuin = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        enableNushellIntegration = true;
      };

      programs.nushell = {
        enable = true;
        shellAliases = shellHelpers.shellAliases;
        extraConfig = ''
          $env.config = {
            show_banner: false
          }
          ${shellHelpers.shellInitScript}
        '';
      };

      programs.zsh = {
        enable = true;
        shellAliases = shellHelpers.shellAliases;
        enableCompletion = true;
        syntaxHighlighting.enable = true;
        autosuggestion.enable = true;
        initContent = ''
          bindkey -r '^L'
          bindkey -r '^J'
          ${shellHelpers.shellInitScript}
        '';
      };

      programs.bash = {
        enable = true;
        shellAliases = shellHelpers.shellAliases;
        enableCompletion = true;
        initExtra = ''
          bind -r '\C-l'
          bind -r '\C-j'
          ${shellHelpers.shellInitScript}
        '';
      };
    };
}
