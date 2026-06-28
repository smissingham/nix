{ inputs, ... }:
let
  pname = "sm-alacritty";
  shiftEnter = builtins.fromJSON ''"\u001b[13;2u"'';
  ctrlSlash = builtins.fromJSON ''"\u001f"'';
in
{
  modules.shared.alacritty =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      package = inputs.wrapper-modules.wrappers.alacritty.wrap {
        inherit pkgs;

        aliases = [ pname ];

        settings = {
          # env.TERM = "xterm-256color";

          window.decorations = "Buttonless";

          font = {
            size = 14;
            normal.family = "JetBrainsMono Nerd Font";
          };

          keyboard.bindings = [
            {
              key = "Return";
              mods = "Shift";
              chars = shiftEnter;
            }
            {
              key = "NumpadEnter";
              mods = "Shift";
              chars = shiftEnter;
            }
            {
              key = "Slash";
              mods = "Control";
              chars = ctrlSlash;
            }
          ];

          colors = {
            primary = {
              background = "#282c34";
              foreground = "#abb2bf";
            };

            cursor = {
              cursor = "#ed8796";
              text = "#282c34";
            };
          };
        };
      };
    in
    {
      options.alacritty.enable = lib.mkEnableOption "Alacritty terminal setup";

      config = lib.mkIf config.alacritty.enable {
        environment.systemPackages = [ package ];
      };
    };
}
