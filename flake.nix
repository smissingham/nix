{
  description = "Sean's Multi-System Flake";

  inputs = {

    # nix
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # agenix (secrets manager)
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    # stylix
    stylix = {
      url = "github:danth/stylix/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Optional: Declarative tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
      nix-darwin,
      home-manager,
      plasma-manager,
      ...
    }:
    let
      inherit (self) outputs;

      overlays = [
        inputs.agenix.overlays.default
      ];

      sharedModules = [ ./modules/shared ];

      darwinModules = sharedModules ++ [
        ./modules/darwin
        home-manager.darwinModules.home-manager
      ];

      nixosModules = sharedModules ++ [
        ./modules/nixos
        inputs.agenix.nixosModules.default
        inputs.home-manager.nixosModules.default
        inputs.stylix.nixosModules.stylix
      ];

      # ----- MAIN USER SETTINGS ----- #
      mainUser = {
        username = "smissingham";
        name = "Sean Missingham";
        email = "sean@missingham.com";
      };

      specialArgs = {
        inherit
          inputs
          outputs
          overlays
          mainUser
          ;
      };
    in
    {

      darwinConfigurations = {
        plutus = nix-darwin.lib.darwinSystem {
          inherit specialArgs;
          system = "aarch64-darwin";
          modules = darwinModules ++ [
            ./hosts/plutus/configuration.nix
            inputs.nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                # Install Homebrew under the default prefix
                enable = true;

                # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
                enableRosetta = true;

                # User owning the Homebrew prefix
                user = mainUser.username;

                # Optional: Declarative tap management
                taps = {
                  "homebrew/homebrew-core" = inputs.homebrew-core;
                  "homebrew/homebrew-cask" = inputs.homebrew-cask;
                  "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
                };

                # Optional: Enable fully-declarative tap management
                # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
                mutableTaps = false;
              };
            }
          ];
        };
      };

      nixosConfigurations = {
        # My home desktop / server
        coeus = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = nixosModules ++ [ ./hosts/coeus/configuration.nix ];
        };

        # kvm sandbox
        thalos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = sharedModules ++ nixosModules ++ [ ./hosts/thalos/configuration.nix ];
        };

      };
    };
}
