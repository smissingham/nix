{ inputs, ... }:
let
  name = "sm-nushell";
in
{
  perSystem =
    {
      config,
      pkgs,
      shell-common,
      ...
    }:
    let
      runtimeInputs = [
        pkgs.atuin
        pkgs.starship
        pkgs.zoxide
        config.packages.sm-television
      ];
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
        inherit name runtimeInputs;
        runtimeEnv = shell-common.env;
        text = ''exec ${wrapped}/bin/nu "$@"'';
      };
    };
}
