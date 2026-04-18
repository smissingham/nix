{ inputs, ... }:
let
  name = "sm-nu";
in
{
  perSystem =
    {
      pkgs,
      shell-common,
      ...
    }:
    let
      wrapped = inputs.wrapper-modules.wrappers.nushell.wrap {
        inherit pkgs;

        "config.nu".content = "${builtins.readFile ./config.nu}\n${
          pkgs.lib.concatStringsSep "\n" (
            pkgs.lib.mapAttrsToList (name: command: "alias ${name} = ${command}") shell-common.aliases
          )
        }";
      };
    in
    {
      packages.${name} = pkgs.writeShellApplication {
        inherit name;
        text = ''exec ${wrapped}/bin/nu "$@"'';
      };
    };
}
