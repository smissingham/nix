{
  description = "Expose all package*.nix files in subdirectories as overlays";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    (flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        # Automatically discover packages from subdirectories
        packageDirs = builtins.attrNames (
          nixpkgs.lib.filterAttrs (_name: type: type == "directory") (builtins.readDir ./.)
        );
        # Build packages from each directory that contains a package*.nix file
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
            # Take the first package file found
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
        validPackages = nixpkgs.lib.filterAttrs (_name: pkg: pkg != null) (
          nixpkgs.lib.genAttrs packageDirs buildPackage
        );
      in
      {
        packages = validPackages;
      }
    ))
    // {
      # Overlays are system-independent
      overlays.customPackages = final: _prev: {
        mypkgs = self.packages.${final.system};
      };
      overlays.default = self.overlays.customPackages;
    };
}
