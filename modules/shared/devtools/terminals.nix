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
    wezterm = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install WezTerm terminal emulator";
    };
    alacritty = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Install Alacritty terminal emulator";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        home-manager.users.${mainUser.username}.home.packages =
          (lib.optionals cfg.wezterm [ pkgsUnstable.wezterm ])
          ++ (lib.optionals cfg.alacritty [ pkgsUnstable.alacritty ]);
      }

      (lib.mkIf cfg.wezterm {
        mySharedModules.home.stows = [ terminalsDots ];
      })
    ]
  );
}
