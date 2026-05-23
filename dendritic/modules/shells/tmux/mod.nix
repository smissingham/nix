{ inputs, ... }:
let
  name = "sm-tmux";
in
{
  perSystem =
    {
      config,
      pkgs,
      ...
    }:
    let

      includedPackages = [
        pkgs.gitmux
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

      gitmuxConfig = pkgs.writeText "gitmux.conf" ''
        tmux:
          styles:
            clear: "#[fg=#{@thm_fg}]"
            state: "#[fg=#{@thm_red},bold]"
            branch: "#[fg=#{@thm_fg},bold]"
            remote: "#[fg=#{@thm_teal}]"
            divergence: "#[fg=#{@thm_fg}]"
            staged: "#[fg=#{@thm_green},bold]"
            conflict: "#[fg=#{@thm_red},bold]"
            modified: "#[fg=#{@thm_yellow},bold]"
            untracked: "#[fg=#{@thm_mauve},bold]"
            stashed: "#[fg=#{@thm_blue},bold]"
            clean: "#[fg=#{@thm_rosewater},bold]"
            insertions: "#[fg=#{@thm_green}]"
            deletions: "#[fg=#{@thm_red}]"
      '';

      wrapped = inputs.wrapper-modules.wrappers.tmux.wrap {
        inherit pkgs;
        aliases = [ name ];

        sourceSensible = false;

        prefix = "C-Space";
        shell = "${config.packages.sm-nushell}/bin/sm-nushell";
        configAfter = builtins.readFile ./tmux.conf;

        plugins = with pkgs.tmuxPlugins; [
          better-mouse-mode
          {
            plugin = vim-tmux-navigator;
            configBefore = ''
              set -g @vim_navigator_prefix_mapping_clear_screen 'C-c'

              is_vim="\
              echo '#{pane_current_command}' | grep -i 'neovim$' && exit 0
              echo '#{pane_current_command}' | grep -iqE '^@vim_navigator_pattern$' && exit 0
              echo '#{pane_current_command}' | grep -iqE '^(bash|zsh|fish|nu)$' && exit 1
              ps -o state= -o comm= -t '#{pane_tty}' \
                  | grep -iqE '^[^TXZ ]+ +@vim_navigator_pattern$'
              "
              set -g @vim_navigator_check "''${is_vim}"
            '';
            configAfter = "";
          }
          {
            plugin = catppuccin;
            # TODO: Fix RAM (not appearing) and gitmux (empty content) and pill spacing
            configAfter = ''
              # Theme
              set -g @catppuccin_flavor "mocha"
              set -g @catppuccin_window_status_style "rounded"
              set -g @catppuccin_status_connect_separator "no"

              # Window labels
              set -g @catppuccin_window_text "#{E:@window_name}"
              set -g @catppuccin_window_current_text "#{E:@window_name}"

              # Status sizing
              set -g status-right-length 100
              set -g status-left-length 100
              set -g status-interval 5

              # Date/time
              set -g @catppuccin_date_time_text " %a %b %-d %-I:%M %p"
              set -g @catppuccin_gitmux_text "#(gitmux -cfg ${gitmuxConfig} \"#{pane_current_path}\")"

              # Left status
              set -g status-left ""
              set -ag status-left "#{E:@catppuccin_status_application}"
              set -ag status-left "#{E:@catppuccin_status_session}"
              set -ag status-left "#{E:@catppuccin_status_directory}"
              set -agF status-left "#{E:@catppuccin_status_gitmux}"

              # Right status
              set -g status-right ""
              set -agF status-right "#{E:@catppuccin_status_cpu}"
              set -agF status-right "#{E:@catppuccin_status_ram}"
              set -agF status-right "#{E:@catppuccin_status_battery}"
              set -ag status-right "#{E:@catppuccin_status_host}"
              set -ag status-right "#{E:@catppuccin_status_user}"
              set -agF status-right "#{E:@catppuccin_status_date_time}"
            '';
          }
          # Load after catppuccin
          battery
          cpu

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
