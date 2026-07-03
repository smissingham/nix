{ inputs, ... }:
let
  pname = "sm-yazi";
in
{
  perSystem =
    { pkgs, ... }:
    let
      tokyo-night = pkgs.fetchFromGitHub {
        owner = "BennyOe";
        repo = "tokyo-night.yazi";
        rev = "main";
        hash = "sha256-LArhRteD7OQRBguV1n13gb5jkl90sOxShkDzgEf3PA0=";
      };
    in
    {
      packages.${pname} = inputs.wrapper-modules.wrappers.yazi.wrap {
        inherit pkgs;
        aliases = [ pname ];

        flavors.tokyo-night = tokyo-night;
        settings.theme.flavor.dark = "tokyo-night";

        settings.yazi.plugin.prepend_previewers = [
          {
            url = "*";
            run = ''piper -- akuna extract --text "$1"'';
          }
        ];

        settings.keymap.mgr.prepend_keymap = [
          {
            on = "?";
            run = "help";
            desc = "Open help";
          }
          {
            on = "<C-u>";
            run = "seek -10";
            desc = "Scroll preview up one page";
          }
          {
            on = "<C-d>";
            run = "seek 10";
            desc = "Scroll preview down one page";
          }
        ];

        plugins = {
          inherit (pkgs.yaziPlugins)
            drag
            full-border
            git
            piper
            smart-enter
            starship
            ;
        };
      };
    };
}
