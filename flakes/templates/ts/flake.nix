{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            nodejs_22
            bun
            typescript
            eslint
            typescript-language-server
          ];

          shellHook = ''
            clear
            echo "----------------------------------------"
            echo "Development Environment Initialised"
            echo "----------------------------------------"
            echo "Node.js: $(node --version)"
            echo "Bun: $(bun --version)"
            echo "TypeScript: $(tsc --version)"
            echo "ESLint: $(eslint --version)"
            echo "----------------------------------------"
          '';
        };
      }
    );
}
