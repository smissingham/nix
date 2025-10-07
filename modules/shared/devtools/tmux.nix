{
  config,
  lib,
  pkgs,
  mainUser,
  ...
}:
let
  moduleSet = "mySharedModules";
  moduleCategory = "devtools";
  moduleName = "tmux";
  moduleDots = "${config.environment.variables.NIX_CONFIG_HOME}/modules/shared/${moduleCategory}/dots/tmux";

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
    mySharedModules.home.stows = [
      "${moduleDots}"
    ];
    mySharedModules.home.shells.aliases = {
      tm = "tmux new-session -A -s";
      s = "sesh_browser";
    };
    mySharedModules.home.shells.scripts = {
      sesh_browser = ''
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
    };

    home-manager.users.${mainUser.username} =
      { ... }:
      {
        home.packages = with pkgs; [
          tmux
          sesh
          fzf
          yazi
        ];
      };

    # TODO: Fix
    #mySharedModules.home.shells.sources = [ "${tmuxSourcePath}" ];
  };
}
