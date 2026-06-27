{ lib, ... }:
let

  # ---------- Simple function alt to Home Manager, provides basic user env/paths etc. ----------#
  mkProfile =
    user:
    {
      config,
      lib,
      options,
      pkgs,
      ...
    }:
    {
      options.user = lib.mkOption {
        type = lib.types.attrs;
        default = { };
        description = "Shared user preferences.";
      };

      config = {
        user = user // rec {
          shell = user.shell // {
            package = pkgs.${user.shell.package};
            path = "${shell.package}/bin/${user.shell.binary}";
          };

          paths = rec {
            home = "${if pkgs.stdenv.isDarwin then "/Users" else "/home"}/${user.username}";
            cache = "${home}/.cache";
            config = "${home}/.config";
            data = "${home}/.local/share";
            state = "${home}/.local/state";
          };

          env = {
            XDG_CACHE_HOME = paths.cache;
            XDG_CONFIG_HOME = paths.config;
            XDG_DATA_HOME = paths.data;
            XDG_STATE_HOME = paths.state;
          }
          // (user.env or { });
        };

        environment.variables = config.user.env;

        users.users.${config.user.username} = {
          description = config.user.name;
          home = config.user.paths.home;
          shell = config.user.shell.path;
        };

        environment.shells = [ config.user.shell.path ];
      }
      // lib.optionalAttrs (options.system ? primaryUser) {
        system.primaryUser = config.user.username;

        system.activationScripts.extraActivation.text = lib.mkAfter ''
          /usr/bin/dscl . -create ${config.user.paths.home} UserShell ${config.user.shell.path}
        '';
      };
    };
in
{
  options.profiles = lib.mkOption {
    type = lib.types.attrs;
    default = { };
    description = "Reusable user profile modules exported by Dendritic.";
  };

  config = {
    profiles.smissingham = mkProfile rec {
      username = "smissingham";
      name = "Sean Missingham";

      apps = {
        browser = "brave-origin";
        editor = "sm-neovim";
        terminal = "sm-alacritty";
      };

      shell = {
        package = "sm-zsh";
        binary = "sm-zsh";
      };

      env = {
        TERM = "xterm-256color";
        BROWSER = apps.browser;
        EDITOR = apps.editor;
      };
    };
  };
}
