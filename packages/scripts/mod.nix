{ lib, ... }:
let
  pname = "sm-scripts";
in
{
  perSystem =
    { pkgs, ... }:
    let
      relativePath = file: lib.removePrefix "${toString ./.}/" (toString file);
      scriptName = file: lib.removeSuffix ".nu" (lib.removeSuffix ".sh" (builtins.baseNameOf file));

      scripts = builtins.filter (
        file:
        !(lib.hasSuffix ".nix" (toString file))
        && (pkgs.stdenv.isDarwin || !(lib.hasPrefix "macos/" (relativePath file)))
      ) (lib.filesystem.listFilesRecursive ./.);

      wrap =
        file:
        let
          command = if lib.hasSuffix ".nu" (toString file) then "nu ${file}" else toString file;
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
        paths = map wrap scripts;
        meta.description = "Sean's utility scripts";
      };
    };
}
