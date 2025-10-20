{
  description = "Nix flake templates";

  outputs =
    let
      # Read all directories in the current directory
      templateDirs = builtins.readDir ./.;

      # Filter to only include directories (not files like flake.nix)
      isTemplate = _name: type: type == "directory";

      # Build templates attribute set from discovered directories
      buildTemplate = name: {
        path = ./. + "/${name}";
        description = "Template: ${name}";
      };

      # Create the templates attribute set
      templates = builtins.listToAttrs (
        map (name: {
          name = name;
          value = buildTemplate name;
        }) (builtins.filter (name: isTemplate name templateDirs.${name}) (builtins.attrNames templateDirs))
      );
    in
    {
      inherit templates;
    };
}
