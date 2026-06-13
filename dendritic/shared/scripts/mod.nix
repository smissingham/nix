{
  flake-parts-lib,
  lib,
  ...
}:
let
  scriptFiles = builtins.filter (file: lib.hasSuffix ".nu" (builtins.toString file)) (
    lib.filesystem.listFilesRecursive ./.
  );

  scriptBinName = file: lib.removeSuffix ".nu" (builtins.baseNameOf file);

  scriptPackageName =
    file:
    let
      relativePath = lib.removePrefix "${toString ./.}/" (toString file);
      relativeName = lib.removeSuffix ".nu" relativePath;
    in
    "scripts-${builtins.replaceStrings [ "/" ] [ "-" ] relativeName}";
in
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (_: {
    options.scripts = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Dendritic script packages.";
    };
  });

  config = {
    perSystem =
      { pkgs, ... }:
      let
        buildScript =
          file:
          pkgs.writeScriptBin (scriptBinName file) ''
            ${builtins.replaceStrings
              [
                "@deadnix@"
                "@jq@"
                "@nixfmt@"
                "@nushell@"
              ]
              [
                "${pkgs.deadnix}"
                "${pkgs.jq}"
                "${pkgs.nixfmt}"
                "${pkgs.nushell}"
              ]
              (builtins.readFile file)
            }
          '';

        systemScriptFiles = builtins.filter (
          file:
          let
            relativePath = lib.removePrefix "${toString ./.}/" (toString file);
          in
          pkgs.stdenv.isDarwin || !(lib.hasPrefix "macos/" relativePath)
        ) scriptFiles;

        scriptPackages = builtins.listToAttrs (
          builtins.map (file: {
            name = scriptPackageName file;
            value = buildScript file;
          }) systemScriptFiles
        );
      in
      {
        packages = scriptPackages;
        scripts = builtins.attrValues scriptPackages;
      };
  };
}
