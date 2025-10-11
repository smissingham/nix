{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  mainUser,
  ...
}:
let
  cfg = config.mySharedModules.devtools.terminals;
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  options.mySharedModules.devtools.terminals = {
    enable = lib.mkEnableOption "terminal emulators";
    wezterm = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install WezTerm terminal emulator";
    };
    ghostty = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Install Ghostty terminal emulator";
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

      (lib.mkIf (!isDarwin && cfg.ghostty) {
        home-manager.users.${mainUser.username}.home.packages = [ pkgsUnstable.ghostty ];
      })

      (lib.mkIf (isDarwin && cfg.ghostty) {
        homebrew.casks = [ "ghostty" ];
      })
    ]
  );
}
