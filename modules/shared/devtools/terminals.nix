{
  config,
  lib,
  pkgsUnstable,
  mainUser,
  ...
}:
let
  moduleCategory = "devtools";
  terminalsDots = "${config.environment.variables.NIX_CONFIG_HOME}/modules/shared/${moduleCategory}/dots/terminals";

  cfg = config.mySharedModules.devtools.terminals;
in
{
  options.mySharedModules.devtools.terminals = {
    enable = lib.mkEnableOption "terminal emulators";
    alacritty = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install Alacritty terminal emulator";
    };
    ghostty = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Install Ghostty terminal emulator";
    };
    wezterm = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install WezTerm terminal emulator";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        home-manager.users.${mainUser.username}.home.packages =
          (lib.optionals cfg.alacritty [ pkgsUnstable.alacritty ])
          ++ (lib.optionals cfg.ghostty [ pkgsUnstable.ghostty ])
          ++ (lib.optionals cfg.wezterm [ pkgsUnstable.wezterm ]);
      }

      (lib.mkIf cfg.wezterm {
        mySharedModules.home.stows = [ terminalsDots ];
      })
    ]
  );
}
