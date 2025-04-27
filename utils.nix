{
  # Function to import all .nix files in a directory
  importDir =
    dir:
    let
      files = builtins.attrNames (builtins.readDir dir);
      nixFiles = builtins.filter (name: builtins.match ".*\\.nix" name != null) files;
    in
    map (name: dir + "/${name}") nixFiles;
}
