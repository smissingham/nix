{
  description = "Sean's Multi-System Flake";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-25.05";
    };
    nixpkgs-unstable = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
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

    mypkgs = {
      url = "path:./packages";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
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
      overlays = [ inputs.mypkgs.overlays.default ];

      isDarwin = system: builtins.match ".*-darwin" system != null;

      # Import all .nix files from a directory recursively and return as module imports
      importDir =
        dir:
        let
          entries = builtins.readDir dir;
          processEntry =
            name: type:
            if type == "regular" && builtins.match ".*\\.nix" name != null then
              [ (dir + "/${name}") ]
            else if type == "directory" then
              (importDir (dir + "/${name}")).imports
            else
              [ ];
          moduleFiles = builtins.concatMap (name: processEntry name entries.${name}) (
            builtins.attrNames entries
          );
        in
        {
          imports = moduleFiles;
        };

      mkSystem =
        {
          mainUser,
          system,
          systemModules,
        }:
        let
          pkgsUnstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
          builder = if isDarwin system then nix-darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
          platformModules =

            # ----- Nix Darwin Modules ----- #
            if isDarwin system then
              [
                (importDir ./modules/darwin)
                inputs.mac-app-util.darwinModules.default
                home-manager.darwinModules.home-manager
                {
                  home-manager.sharedModules = [
                    inputs.mac-app-util.homeManagerModules.default
                  ];
                }
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
              ]

            # ----- NixOS Modules -----#
            else
              [
                (importDir ./modules/nixos)
                home-manager.nixosModules.default
              ];

          # ------ Modules Shared Across All Systems -----#
          sharedModules = [ (importDir ./modules/shared) ];
        in
        builder {
          inherit system;
          modules = systemModules ++ sharedModules ++ platformModules ++ [ { nixpkgs.overlays = overlays; } ];
          specialArgs = {
            inherit
              inputs
              outputs
              overlays
              mainUser
              pkgsUnstable
              ;
          };
        };
    in
    {
      darwinConfigurations = {
        plutus = mkSystem {
          mainUser = import ./profiles/smissingham/default.nix;
          system = "aarch64-darwin";
          systemModules = [
            ./hosts/plutus/configuration.nix
          ];
        };
        popmart = mkSystem {
          system = "aarch64-darwin";
          systemModules = [
            ./hosts/popmart/configuration.nix
          ];
        };
      };

      nixosConfigurations = {
        coeus = mkSystem {
          mainUser = import ./profiles/smissingham/default.nix;
          system = "x86_64-linux";
          systemModules = [
            ./hosts/coeus/configuration.nix
          ];
        };
      };
    };
}
