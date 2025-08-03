{
  description = "Custom packages for Sean's Nix setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs@{
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
          config.allowUnfree = true;
        };

      pkgsUnstableFor =
        system:
        import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
          pkgsUnstable = pkgsUnstableFor system;
        in
        {
          filen-desktop = pkgs.callPackage ./filen-desktop/package.appimage.nix { };
          claude-code = pkgs.callPackage ./claude-code/package.nix { };
        }
      );

      overlays.default = final: prev: {
        mypkgs = self.packages.${final.system};
      };
    };
}
