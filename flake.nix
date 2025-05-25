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
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
      nix-darwin,
      home-manager,
      ...
    }:
    let
      inherit (self) outputs;
      overlays = [ ];

      importDir =
        dir:
        let
          entries = builtins.readDir dir;
          processEntry =
            name: type:
            if type == "regular" && builtins.match ".*\\.nix" name != null then
              [ (dir + "/${name}") ]
            else if type == "directory" then
              importDir (dir + "/${name}")
            else
              [ ];
        in
        builtins.concatMap (name: processEntry name entries.${name}) (builtins.attrNames entries);

      importDarwinModules = {
        imports = importDir ./modules/darwin;
      };
      importNixosModules = {
        imports = importDir ./modules/nixos;
      };
      importSharedModules = {
        imports = importDir ./modules/shared;
      };

      sharedModules = [ importSharedModules ];
      darwinModules = sharedModules ++ [
        importDarwinModules
        home-manager.darwinModules.home-manager
      ];
      nixosModules = sharedModules ++ [
        importNixosModules
        home-manager.nixosModules.default
      ];

      # Function to determine if a system is Darwin based on the system string
      isDarwin = system: builtins.match ".*-darwin" system != null;

      # Function to create mainUser with the correct homeDir based on system
      mkMainUser = system: {
        username = "smissingham";
        name = "Sean Missingham";
        email = "sean@missingham.com";
        homeDir = (if isDarwin system then "/Users" else "/home") + "/smissingham";
        dotsPath = ./dots;
        terminalApp = "ghostty";
      };

      specialArgs = system: {
        inherit
          inputs
          outputs
          overlays
          ;
        mainUser = mkMainUser system;
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
          args = specialArgs system;
          extendedArgs = args // {
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
                user = (mkMainUser "aarch64-darwin").username;
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
