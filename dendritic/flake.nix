{
  description = "Reusable nix components and exposed packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    import-tree.url = "github:vic/import-tree";

    # https://birdeehub.github.io/nix-wrapper-modules/md/wrapper-modules.html
    wrapper-modules = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    inputs@{ ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.flake-parts.flakeModules.easyOverlay
        (inputs.import-tree ./darwin)
        (inputs.import-tree ./shared)
      ];

      options.flake.darwinModules = inputs.nixpkgs.lib.mkOption {
        type = inputs.nixpkgs.lib.types.attrs;
        default = { };
        description = "nix-darwin modules exported by Dendritic.";
      };

      options.flake.defaults = inputs.nixpkgs.lib.mkOption {
        type = inputs.nixpkgs.lib.types.attrs;
        default = { };
        description = "Shared Dendritic default values.";
      };

      options.flake.paths = inputs.nixpkgs.lib.mkOption {
        type = inputs.nixpkgs.lib.types.attrs;
        default = { };
        description = "Shared Dendritic filesystem paths.";
      };

      options.flake.shells = inputs.nixpkgs.lib.mkOption {
        type = inputs.nixpkgs.lib.types.attrs;
        default = { };
        description = "Shared Dendritic shell settings.";
      };

      config = {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ];

        perSystem =
          { config, system, ... }:
          {
            _module.args.pkgs-stable = import inputs.nixpkgs-stable {
              inherit system;
            };

            overlayAttrs = config.packages;
          };
      };
    };
}
