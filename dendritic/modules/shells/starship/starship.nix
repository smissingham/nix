{ ... }:
let
  appName = "sm-starship";
in
{
  perSystem =
    { pkgs, ... }:
    let
      starshipConfig = (pkgs.formats.toml { }).generate "starship.toml" {
        shell = {
          disabled = false;
          format = "[$symbol]($style) ";
        };
      };
    in
    {
      packages.${appName} = pkgs.writeShellApplication {
        name = "starship";
        runtimeInputs = [ pkgs.starship ];
        text = ''
          export STARSHIP_CONFIG=${starshipConfig}
          exec ${pkgs.starship}/bin/starship "$@"
        '';
      };
    };
}
