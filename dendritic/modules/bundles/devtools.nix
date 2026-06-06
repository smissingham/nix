# Bulk install package for systems, dev shells, and containers that need the
# shared dev toolset without using sm-shell as their login/runtime entrypoint.
{ ... }:
let
  name = "sm-bundle-devtools";
in
{
  perSystem =
    {
      config,
      pkgs,
      shell-common,
      ...
    }:
    {
      packages.${name} = pkgs.symlinkJoin {
        inherit name;
        paths = [
          config.packages.sm-shell
          config.packages.sm-cli-tools
          config.packages.sm-tmux
          config.packages.sm-nushell
        ];
      };

      devShells.default = pkgs.mkShell {
        packages = [ config.packages.${name} ];
      };
    };
}
