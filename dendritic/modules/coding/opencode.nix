{ inputs, ... }:
let
  name = "sm-opencode";
in
{
  perSystem =
    { pkgs, ... }:
    let
      runtimeInputs = [ ];
      wrapped = inputs.wrapper-modules.wrappers.opencode.wrap {
        inherit pkgs;

        env = {
          OPENCODE_CONFIG = "$HOME/.config/${name}";
        };
      };
    in
    {

      packages.${name} = pkgs.writeShellApplication {
        inherit name runtimeInputs;
        text = ''exec ${wrapped}/bin/opencode "$@"'';
      };
    };
}
