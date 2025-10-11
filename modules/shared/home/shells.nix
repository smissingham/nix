{
  lib,
  pkgs,
  config,
  mainUser,
  ...
}:
let
  moduleSet = "mySharedModules";
  moduleCategory = "home";
  moduleName = "shells";

  optionPath = [
    moduleSet
    moduleCategory
    moduleName
  ];

  aliasesOptionAttr = lib.getAttrFromPath (optionPath ++ [ "aliases" ]) config;
  scriptsOptionAttr = lib.getAttrFromPath (optionPath ++ [ "scripts" ]) config;
in
{
  options = lib.setAttrByPath optionPath {
    aliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      description = "Shell aliases to add to shells";
      default = { };
    };
    scripts = lib.mkOption {
      type = lib.types.attrsOf lib.types.lines;
      description = "Shell scripts to write as bins";
      default = { };
    };
  };

  config = {
    home-manager.users.${mainUser.username} =
      {
        lib,
        ...
      }:
      let

        shellAliases = lib.mkMerge [
          mainUser.shellAliases
          aliasesOptionAttr
        ];

        shellInitScript = ''
          clear
        '';
      in
      {
        home.packages =
          with pkgs;
          [
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
          ]
          # Convert script definitions from other modules into executable bins
          ++ (lib.mapAttrsToList (name: script: pkgs.writeShellScriptBin name script) scriptsOptionAttr);

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

        programs.direnv = {
          enable = true;
          nix-direnv.enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
        };

        programs.zoxide = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
        };

        programs.starship = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          enableNushellIntegration = true;
        };

        programs.atuin = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          enableNushellIntegration = true;
        };

        programs.nushell = {
          enable = true;
          shellAliases = shellAliases;
          extraConfig = ''
            $env.config = {
              show_banner: false
            }
            ${shellInitScript}
          '';
        };

        programs.zsh = {
          enable = true;
          shellAliases = shellAliases;
          enableCompletion = true;
          syntaxHighlighting.enable = true;
          autosuggestion.enable = true;
          initContent = ''
            bindkey -r '^L'
            bindkey -r '^J'
            ${shellInitScript}
          '';
        };

        programs.bash = {
          enable = true;
          shellAliases = shellAliases;
          enableCompletion = true;
          initExtra = ''
            bind -r '\C-l'
            bind -r '\C-j'
            ${shellInitScript}
          '';
        };
      };
  };
}
