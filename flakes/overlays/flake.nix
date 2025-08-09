{
  description = "Expose all package*.nix files in subdirectories as overlays";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            allowUnsupportedSystem = true;
            allowBroken = true;
          };
        };

      pkgsUnstableFor =
        system:
        import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
    in
    {
      # Custom packages - these are the actual package definitions
      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
          pkgsUnstable = pkgsUnstableFor system;

          # Automatically discover packages from subdirectories
          packageDirs = builtins.attrNames (
            nixpkgs.lib.filterAttrs (name: type: type == "directory") (builtins.readDir ./.)
          );

          # Build packages from each directory that contains a package*.nix file
          # Handle platform-specific packages gracefully
          buildPackage =
            dir:
            let
              dirPath = ./${dir};
              dirContents = builtins.readDir dirPath;
              # Find all files that start with "package" and end with ".nix"
              packageFiles = nixpkgs.lib.filterAttrs (
                name: type:
                type == "regular" && nixpkgs.lib.hasPrefix "package" name && nixpkgs.lib.hasSuffix ".nix" name
              ) dirContents;
              packageFileNames = builtins.attrNames packageFiles;
              # Take the first package file found (could be enhanced to prioritize certain patterns)
              firstPackageFile = if packageFileNames != [ ] then builtins.head packageFileNames else null;
            in
            if firstPackageFile != null then
              let
                result = builtins.tryEval (pkgs.callPackage (dirPath + "/${firstPackageFile}") { });
              in
              if result.success then result.value else null
            else
              null;

          # Create attribute set of all valid packages
          validPackages = nixpkgs.lib.filterAttrs (name: pkg: pkg != null) (
            nixpkgs.lib.genAttrs packageDirs buildPackage
          );
        in
        validPackages
      );

      # Overlay - makes custom packages available in nixpkgs as 'seanCustomPkgs'
      overlays.customPackages = final: prev: {
        mypkgs = self.packages.${final.system};
      };

      # Default overlay for backward compatibility
      overlays.default = self.overlays.customPackages;
    };
}
