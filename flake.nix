rec {
  description = "Reusable nix components and exposed packages";

  nixConfig.extra-experimental-features = [
    "nix-command"
    "flakes"
    "pipe-operators"
  ];

  inputs = {
    # ---------- Nix Base ---------- #
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # ---------- Core Flake Organisation ---------- #
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    # ---------- Custom Package Sources ---------- #
    mypkgs.url = "github:smissingham/nixpkgs/develop";
    microvm-nix.url = "github:microvm-nix/microvm.nix";
    microvm-nix.inputs.nixpkgs.follows = "nixpkgs";
    nixos-cix-cd8180.url = "github:i-am-logger/nixos-cix-cd8180";
    nixos-cix-cd8180.inputs.nixpkgs.follows = "nixpkgs";

    # ---------- Nix on Darwin ---------- #
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core.url = "github:homebrew/homebrew-core";
    homebrew-core.flake = false;
    homebrew-cask.url = "github:homebrew/homebrew-cask";
    homebrew-cask.flake = false;
    homebrew-bundle.url = "github:homebrew/homebrew-bundle";
    homebrew-bundle.flake = false;
  };

  outputs =
    inputs@{ ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { config, lib, ... }:
      let
        nixExperimentalFeatures = nixConfig.extra-experimental-features;

        # Keep compatibility versions centralized so hosts cannot drift.
        nixosStateVersion = inputs.nixpkgs.lib.trivial.release;
        darwinStateVersion = 5;

        isDarwin = system: builtins.match ".*-darwin" system != null;

        # Turn every ./wrappers/<name>.nix into a wrapped module attr named <name>.
        localWrappers = lib.pipe (builtins.readDir ./wrappers) [
          (lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".nix" name))
          (lib.mapAttrs' (
            name: _:
            lib.nameValuePair (lib.removeSuffix ".nix" name) (
              inputs.wrapper-modules.lib.wrapModule ./wrappers/${name}
            )
          ))
        ];

        # Expose local wrappers through same namespace as upstream wrapper-modules.
        # Local names win, so ./wrappers/foo.nix overrides upstream wrappers.foo.
        wrappedInputs = inputs // {
          wrapper-modules = inputs.wrapper-modules // {
            wrappers = inputs.wrapper-modules.wrappers // localWrappers;
          };
        };

        # Build one host record from config.hosts.<name>.
        # Each host owns its platform and module; root injects shared flake policy.
        mkHostSystem =
          host:
          let
            pkgsunstable = import inputs.nixpkgs-unstable {
              inherit (host) system;
              config.allowUnfree = true;
            };
            builder =
              if isDarwin host.system then
                inputs.nix-darwin.lib.darwinSystem
              else
                inputs.nixpkgs.lib.nixosSystem;
          in
          builder {
            # Host modules receive wrapper-modules with local wrapper overlay applied.
            specialArgs = {
              inputs = wrappedInputs;
              inherit pkgsunstable;
              inherit nixExperimentalFeatures;
            };
            modules = [
              host.module

              # Root-owned system defaults shared by every host.
              {
                nixpkgs.hostPlatform = host.system;
                nixpkgs.overlays = [
                  config.flake.overlays.default
                ];

                system.stateVersion =
                  if isDarwin host.system then darwinStateVersion else nixosStateVersion;
              }
            ];
          };

        # Split host records into nix-darwin and NixOS flake outputs.
        mkHostConfigs =
          predicate:
          builtins.mapAttrs (_: mkHostSystem) (
            lib.filterAttrs (
              _: host:
              builtins.isAttrs host
              && builtins.hasAttr "system" host
              && builtins.hasAttr "module" host
              && predicate host.system
            ) config.hosts
          );
      in
      {
        imports = [
          inputs.flake-parts.flakeModules.easyOverlay
          (inputs.import-tree ./hosts)
          (inputs.import-tree ./modules)
          (inputs.import-tree ./packages)
          (inputs.import-tree ./containers)
        ];

        config = {
          flake = {
            darwinConfigurations = mkHostConfigs isDarwin;
            nixosConfigurations = mkHostConfigs (system: !isDarwin system);
          };

          systems = [
            "x86_64-linux"
            "aarch64-linux"
            "aarch64-darwin"
          ];

          perSystem =
            { config, ... }:
            {
              overlayAttrs = config.packages;
            };
        };
      }
    );
}
