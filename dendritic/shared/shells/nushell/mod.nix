{ config, inputs, ... }:
let
  name = "sm-nushell";
  shells = config.flake.shells;
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
        config.packages.sm-neovim
        config.packages.sm-television
      ];
      wrapped = inputs.wrapper-modules.wrappers.nushell.wrap {
        inherit pkgs;

        env = shells.env;
        prefixVar = [
          [
            "PATH"
            ":"
            (pkgs.lib.concatStringsSep ":" shells.path)
          ]
        ];
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
        runtimeEnv = shells.env;
        text = ''exec ${wrapped}/bin/nu "$@"'';
      };
    };
}
