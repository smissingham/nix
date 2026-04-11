{ inputs, ... }:
let
  appName = "sm-zsh";
in
{
  perSystem =
    {
      pkgs,
      cliCommon,
      ...
    }:
    let
      wrappedZsh = inputs.wrapper-modules.wrappers.zsh.wrap {
        inherit pkgs;

        skipGlobalRC = true;
        zdotdir = "$HOME/.config/${appName}";

        zshAliases = cliCommon.aliases;
        extraPackages = cliCommon.packages;
      };
    in
    {
      packages.${appName} = pkgs.writeShellApplication {
        name = appName;
        runtimeInputs = cliCommon.packages;
        text = ''
          stow-configs
          prompt-welcome "${appName}"
          exec ${wrappedZsh}/bin/zsh "$@"
        '';
      };
    };
}
