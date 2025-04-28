{
  description = "Sean's Multi-System Flake";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-24.11";
    };
    nixpkgs-unstable = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    stylix = {
      url = "github:danth/stylix/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    my-nixvim = {
      url = "path:./flakes/nixvim";
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
      my-nixvim,
      ...
    }:
    let
      inherit (self) outputs;

      myUtils = import ./myUtils.nix;

      overlays = [ inputs.agenix.overlays.default ];

      sharedModules = [ ./modules/shared ];
      darwinModules = sharedModules ++ [
        ./modules/darwin
        home-manager.darwinModules.home-manager
      ];
      nixosModules = sharedModules ++ [
        ./modules/nixos
        inputs.agenix.nixosModules.default
        home-manager.nixosModules.default
        inputs.stylix.nixosModules.stylix
      ];

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
          myUtils
          ;
        rootPath = ./.;
      };

      mkSystem =
        {
          system,
          builder,
          modules,
        }:
        let
          pkgsUnstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
          extendedArgs = specialArgs // {
            inherit pkgsUnstable;
          };
        in
        builder {
          inherit system;
          specialArgs = extendedArgs;
          modules = modules;
        };

    in
    {
      darwinConfigurations = {
        plutus = mkSystem {
          system = "aarch64-darwin";
          builder = nix-darwin.lib.darwinSystem;
          modules = darwinModules ++ [
            ./hosts/plutus/configuration.nix
            inputs.nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                enable = true;
                enableRosetta = true;
                user = mainUser.username;
                taps = {
                  "homebrew/homebrew-core" = inputs.homebrew-core;
                  "homebrew/homebrew-cask" = inputs.homebrew-cask;
                  "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
                };
                mutableTaps = false;
              };
            }
          ];
        };
      };

      nixosConfigurations = {
        coeus = mkSystem {
          system = "x86_64-linux";
          builder = nixpkgs.lib.nixosSystem;
          modules = nixosModules ++ [ ./hosts/coeus/configuration.nix ];
        };

        thalos = mkSystem {
          system = "x86_64-linux";
          builder = nixpkgs.lib.nixosSystem;
          modules = nixosModules ++ [ ./hosts/thalos/configuration.nix ];
        };
      };
    };
}
