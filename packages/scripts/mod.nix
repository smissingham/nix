{ lib, ... }:
let
  pname = "sm-scripts";
in
{
  perSystem =
    { pkgs, ... }:
    let
      relativePath = file: file |> toString |> lib.removePrefix "${toString ./.}/";
      scriptName =
        file: baseNameOf file |> lib.removeSuffix ".sh" |> lib.removeSuffix ".nu";

      scripts =
        lib.filesystem.listFilesRecursive ./.
        |> builtins.filter (
          file:
          !(lib.hasSuffix ".nix" (toString file))
          && (pkgs.stdenv.isDarwin || !(lib.hasPrefix "macos/" (relativePath file)))
        );

      wrap =
        file:
        let
          command =
            if lib.hasSuffix ".nu" (toString file) then "nu ${file}" else toString file;
        in
        pkgs.writeShellApplication {
          name = scriptName file;
          runtimeInputs = [
            pkgs.deadnix
            pkgs.nixfmt
            pkgs.nushell
            pkgs.patchelf
            pkgs.stow
          ];
          text = ''exec ${command} "$@"'';
        };
    in
    {
      packages.${pname} = pkgs.symlinkJoin {
        name = pname;
        paths = scripts |> map wrap;
        meta.description = "Sean's utility scripts";
      };
    };
}
