{
  config,
  lib,
  pkgs,
  mainUser,
  ...
}:
let
  moduleSet = "mySharedModules";
  moduleCategory = "workflow";
  moduleName = "sesh";
  moduleDots = "${config.environment.variables.NIX_CONFIG_HOME}/dots/modules/${moduleCategory}/${moduleName}";

  optionPath = [
    moduleSet
    moduleCategory
    moduleName
  ];
  enablePath = optionPath ++ [ "enable" ];
in
{
  options = lib.setAttrByPath optionPath {
    enable = lib.mkEnableOption moduleName;
  };

  config = lib.mkIf (lib.getAttrFromPath enablePath config) {
    mySharedModules.workflow.shell.stowPaths = [
      "${moduleDots}"
    ];
    mySharedModules.workflow.shell.aliases = {
      s = "sesh-browser";
    };

    home-manager.users.${mainUser.username} =
      {
        pkgs,
        ...
      }:
      let
        seshBrowserScript = pkgs.writeShellScriptBin "sesh-browser" ''
          sesh connect "$(
            sesh list --icons | fzf-tmux -p 80%,70% \
              --preview-window 'right:70%' \
              --preview 'sesh preview {}' \
              --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
              --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
              --bind 'tab:down,btab:up' \
              --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
              --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
              --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
              --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
              --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
              --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
          )"
        '';
      in
      {
        imports = [ ];
        home = {
          packages = with pkgs; [
            yazi
            tmux
            sesh
            fzf
            eza
            bat
            seshBrowserScript
          ];
        };
      };
  };
}
