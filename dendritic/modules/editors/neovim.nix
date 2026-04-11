{ inputs, ... }:
let
  appName = "sm-neovim";
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.${appName} = inputs.wrapper-modules.wrappers.neovim.wrap {
        inherit pkgs;

        env = {
          NVIM_APPNAME = appName;
        };

        settings = {
          aliases = [
            appName
          ];
        };
      };
    };
}
