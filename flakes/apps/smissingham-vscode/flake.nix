{
  description = "Portable VSCodium Configuration Flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;
        vscodiumConfigured = import ./vscode.nix { inherit pkgs lib; };
      in
      {
        packages = {
          default = vscodiumConfigured;
          smissingham-vscode = vscodiumConfigured;
          systemPackages = [ vscodiumConfigured ];
        };

        apps = {
          default = {
            type = "app";
            program = "${vscodiumConfigured}/bin/codium";
          };
        };
      }
    )
    // {
      sharedModules.default =
        {
          pkgs,
          ...
        }:
        {
          environment.systemPackages = self.packages.${pkgs.system}.systemPackages;
        };
    };
}
