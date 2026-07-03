{ inputs, lib, ... }:
let
  pname = "sm-television";
in
{
  perSystem =
    { pkgs, ... }:
    let
      channels =
        builtins.readDir ./cable
        |> lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".toml" name)
        |> lib.mapAttrs' (
          name: _: lib.nameValuePair (lib.removeSuffix ".toml" name) ./cable/${name}
        );

      wrapped = inputs.wrapper-modules.wrappers.television.wrap {
        inherit pkgs;
        aliases = [ pname ];
        settings = ./config.toml |> builtins.readFile |> fromTOML;
        inherit channels;
      };
    in
    {
      packages.${pname} = pkgs.symlinkJoin {
        name = pname;
        paths = [
          wrapped
          pkgs.nix-search-tv
        ];
        meta.description = "Sean's wrapped television fuzzy finder";
      };
    };
}
