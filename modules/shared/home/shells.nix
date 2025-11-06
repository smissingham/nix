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
    programs.zsh.enable = true;
    users.users.${mainUser.username} = {
      shell = pkgs.zsh;
    };
    home-manager.users.${mainUser.username} =
      {
        lib,
        config,
        ...
      }:
      let

        allShellAliases = config.home.shellAliases // mainUser.shellAliases // aliasesOptionAttr;

        shellInitScript = ''
          clear
          fastfetch --structure os:kernel:shell:terminal:cpu:memory:disk --logo none
        '';

        # Generate aliases for nushell as 'custom commands' to support chaining in aliases
        nushellAliasConfig = lib.concatStringsSep "\n" (
          lib.mapAttrsToList (
            name: value:
            let
              commands = builtins.filter (cmd: cmd != "") (
                map lib.strings.trim (lib.splitString ";" (builtins.replaceStrings [ "&&" ] [ ";" ] value))
              );
            in
            ''
              def ${name} [] {
                ${lib.concatMapStringsSep "\n  " (cmd: cmd) commands}
              }
            ''
          ) allShellAliases
        );
      in
      {
        home.packages =
          with pkgs;
          [
            # System utilities
            pciutils
            usbutils
            findutils
            fastfetch

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
            _7zz
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

        programs.bash = {
          enable = true;
          shellAliases = allShellAliases;
          enableCompletion = true;
          initExtra = ''
            bind -r '\C-l'
            bind -r '\C-j'
            ${shellInitScript}
          '';
        };
        programs.zsh = {
          enable = true;
          shellAliases = allShellAliases;
          enableCompletion = true;
          syntaxHighlighting.enable = true;
          autosuggestion.enable = true;
          initContent = ''
            bindkey -r '^L'
            bindkey -r '^J'
            ${shellInitScript}
          '';
        };

        programs.nushell = {
          enable = true;
          # Write empty aliases, handle them specially for nushell to support chaining
          shellAliases = lib.mkForce { };
          extraConfig = ''
            $env.config = {
              show_banner: false
            }

            ${nushellAliasConfig}
            ${shellInitScript}
          '';
        };
      };
  };
}
