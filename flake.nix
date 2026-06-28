{
  description = "Reusable nix components and exposed packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    microvm-nix.url = "github:microvm-nix/microvm.nix";
    microvm-nix.inputs.nixpkgs.follows = "nixpkgs";

    mypkgs.url = "github:smissingham/nixpkgs/develop";

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
        # Keep compatibility versions centralized so hosts cannot drift.
        nixosStateVersion = inputs.nixpkgs-stable.lib.trivial.release;
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
            pkgsstable = import inputs.nixpkgs-stable {
              inherit (host) system;
            };
            builder =
              if isDarwin host.system then inputs.nix-darwin.lib.darwinSystem else inputs.nixpkgs.lib.nixosSystem;
          in
          builder {
            # Host modules receive wrapper-modules with local wrapper overlay applied.
            specialArgs = {
              inputs = wrappedInputs;
              inherit pkgsstable;
            };
            modules = [
              host.module

              # Root-owned system defaults shared by every host.
              {
                nixpkgs.hostPlatform = host.system;
                nixpkgs.overlays = [
                  config.flake.overlays.default
                ];

                system.stateVersion = if isDarwin host.system then darwinStateVersion else nixosStateVersion;
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
