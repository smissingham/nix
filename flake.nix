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
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    stylix = {
      url = "github:danth/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
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
      url = "path:flakes/overlays";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
    };
    myapps = {
      url = "path:flakes/apps";
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
      overlays = [
        inputs.mypkgs.overlays.default
        inputs.myapps.overlays.default
      ];

      isDarwin = system: builtins.match ".*-darwin" system != null;

      importDir =
        dir:
        if !builtins.pathExists dir then
          { imports = [ ]; }
        else
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
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          pkgsUnstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
          serviceUtils = import ./lib/services.nix {
            inherit (nixpkgs) lib;
            inherit pkgs;
          };
          builder = if isDarwin system then nix-darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
          privateModulesPath = mainUser.getPrivateModulesPath { };
          platformModules =

            # ----- Nix Darwin Modules ----- #
            if isDarwin system then
              [
                (importDir ./modules/darwin)
                home-manager.darwinModules.home-manager
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
              ++ [ (importDir (privateModulesPath + "/darwin")) ]

            # ----- NixOS Modules -----#
            else
              [
                (importDir ./modules/nixos)
                home-manager.nixosModules.default
                inputs.stylix.nixosModules.stylix
              ]
              ++ [ (importDir (privateModulesPath + "/nixos")) ];

          sharedModules = [
            (importDir ./modules/shared)
            (importDir (privateModulesPath + "/shared"))
          ];
        in
        builder {
          inherit system;
          modules = systemModules ++ sharedModules ++ platformModules ++ [ { nixpkgs.overlays = overlays; } ];
          specialArgs = {
            inherit
              inputs
              outputs
              overlays
              pkgsUnstable
              mainUser
              serviceUtils
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
