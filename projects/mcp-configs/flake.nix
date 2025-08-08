{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs_22
            bun
            typescript
            nodePackages.eslint
            nodePackages.typescript-language-server
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
