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
          #fastfetch
        '';
      in
      {
        home.packages =
          with pkgs;
          [
            xclip
          ]
          # Convert script definitions and aliases from other modules into executable bins
          ++ (lib.mapAttrsToList (name: alias: pkgs.writeShellScriptBin name alias) aliasesOptionAttr)
          ++ (lib.mapAttrsToList (name: script: pkgs.writeShellScriptBin name script) scriptsOptionAttr);

        programs.git = {
          enable = true;
          settings.user = {
            name = mainUser.name;
            email = mainUser.email;
          };
        };

        programs.delta = {
          enable = true;
          enableGitIntegration = true;
          options = {
            navigate = true;
            line-numbers = true;
            dark = true;
          };
        };

        programs.zoxide = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
        };

        # programs.direnv = {
        #   enable = true;
        #   enableBashIntegration = true;
        #   enableZshIntegration = true;
        #   nix-direnv.enable = true;
        # };

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
      };
  };
}
