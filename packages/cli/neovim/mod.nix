{ inputs, ... }:
let
  pname = "sm-neovim";
in
{
  perSystem =
    {
      pkgs,
      sm-bundles,
      ...
    }:
    let
      delta = pkgs.writeShellScriptBin "delta" ''
        exec ${pkgs.delta}/bin/delta --navigate --line-numbers --dark "$@"
      '';

      # packages to be installed alongside app
      includedPackages =
        sm-bundles.cli-core
        ++ sm-bundles.cli-dev
        ++ sm-bundles.cli-lang
        ++ [
          # local wrappers
          delta
        ];

      # the wrapped neovim app runtime
      wrapped = inputs.wrapper-modules.wrappers.neovim.wrap {
        inherit pkgs;

        env = {
          NVIM_APPNAME = pname;
          #PATH = pkgs.lib.makeBinPath includedPackages;
        };

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
