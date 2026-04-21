{ inputs, ... }:
let
  name = "sm-tmux";
in
{
  perSystem =
    {
      pkgs,
      ...
    }:
    let

      includedPackages = [
        pkgs.sesh
        (pkgs.writeShellScriptBin "sesh_browser" ''
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
        '')
      ];

      wrapped = inputs.wrapper-modules.wrappers.tmux.wrap {
        inherit pkgs;
        aliases = [ name ];

        prefix = "C-Space";
        configAfter = builtins.readFile ./tmux.conf;

        plugins = with pkgs.tmuxPlugins; [
          battery
          better-mouse-mode
          cpu
          {
            plugin = vim-tmux-navigator;
            configAfter = ''
              # Configure vim-tmux-navigator to use C-c for clear screen instead of C-l
              set -g @vim_navigator_prefix_mapping_clear_screen 'C-c'

              # Improve detection of nvim (wasn't working on macos when inside tmux)
              is_vim="\
              echo '#{pane_current_command}' | grep -iqE '^@vim_navigator_pattern$' && exit 0
              echo '#{pane_current_command}' | grep -iqE '^(bash|zsh|fish)$' && exit 1
              ps -o state= -o comm= -t '#{pane_tty}' \
                  | grep -iqE '^[^TXZ ]+ +@vim_navigator_pattern$'"
              set -g @vim_navigator_check "$${is_vim}"
            '';
          }
          {
            plugin = catppuccin;
            configAfter = ''
              # Configure the catppuccin plugin
              set -g @catppuccin_flavor "mocha"
              set -g @catppuccin_window_status_style "rounded"
              set -g @catppuccin_window_text "#{E:@window_name}"
              set -g @catppuccin_window_current_text "#{E:@window_name}"
              set -g status-right-length 100
              set -g status-left-length 100
              set -g status-left ""
              set -g status-right "#{E:@catppuccin_status_application}"
              set -agF status-right "#{E:@catppuccin_status_cpu}"
              set -ag status-right "#{E:@catppuccin_status_session}"
              set -ag status-right "#{E:@catppuccin_status_uptime}"
              set -agF status-right "#{E:@catppuccin_status_battery}"
            '';
          }

        ];
      };
    in
    {
      packages.${name} = pkgs.symlinkJoin {
        name = name;
        paths = [ wrapped ] ++ includedPackages;
      };
    };
}
