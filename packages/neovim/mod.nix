{ inputs, ... }:
let
  pname = "sm-neovim";
in
{
  perSystem =
    {
      pkgs,
      sm-clibundles,
      ...
    }:
    let
      delta = pkgs.writeShellScriptBin "delta" ''
        exec ${pkgs.delta}/bin/delta --navigate --line-numbers --dark "$@"
      '';

      # packages to be installed alongside app
      includedPackages = [
        pkgs.pandoc
        delta
      ]
      ++ sm-clibundles.core
      ++ sm-clibundles.dev
      ++ sm-clibundles.lang;

      # the wrapped neovim app runtime
      wrapped = inputs.wrapper-modules.wrappers.neovim.wrap {
        inherit pkgs;

        env.NVIM_APPNAME = pname;

        settings = {
          config_directory = ./.;
          dont_link = true;
          binName = pname;
          aliases = [
            pname
          ];
        };
      };

      package = pkgs.symlinkJoin {
        name = pname;
        paths = [ wrapped ] ++ includedPackages;
        meta.description = "Sean's wrapped Neovim editor";
      };
    in
    {
      packages.${pname} = package;
    };
}
