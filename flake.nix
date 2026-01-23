{
  description = "Sean's Multi-System Flake";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-25.11";
    };
    nixpkgs-unstable = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    stylix = {
      url = "github:danth/stylix/release-25.11";
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
    mynixpkgs = {
      url = "github:smissingham/nixpkgs/develop";
    };
    myoverlays = {
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
      stateVersion = nixpkgs.lib.trivial.release;
      inherit (self) outputs;
      overlays = [
        inputs.myoverlays.overlays.default
        inputs.myapps.overlays.default
        (_final: prev: {
          mynixpkgs = import inputs.mynixpkgs {
            #inherit (prev) system;
            config = prev.config;
          };
        })
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

      mkBase =
        { mainUser }:
        let
          pkgs = import nixpkgs {
            #inherit system;
            config.allowUnfree = true;
          };
          pkgsUnstable = import nixpkgs-unstable {
            #inherit system;
            config.allowUnfree = true;
          };
          serviceUtils = import ./lib/services.nix {
            inherit (nixpkgs) lib;
            inherit pkgs;
          };
          privateModulesPath = mainUser.getPrivateModulesPath { };
        in
        {
          inherit
            pkgs
            pkgsUnstable
            serviceUtils
            privateModulesPath
            ;

          specialArgs = {
            inherit
              inputs
              outputs
              overlays
              stateVersion
              pkgsUnstable
              mainUser
              serviceUtils
              ;
          };

          sharedModules = [
            (importDir ./modules/shared)
            (importDir (privateModulesPath + "/shared"))
            { nixpkgs.overlays = overlays; }
          ];

          nixosModules = [
            (importDir ./modules/nixos)
            home-manager.nixosModules.default
            inputs.stylix.nixosModules.stylix
            (importDir (privateModulesPath + "/nixos"))
          ];
        };

      mkSystem =
        {
          mainUser,
          system,
          systemModules,
        }:
        let
          base = mkBase { inherit mainUser; };
          platformModules =
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
                (importDir (base.privateModulesPath + "/darwin"))
              ]
            else
              base.nixosModules;
          builder = if isDarwin system then nix-darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
        in
        builder {
          #inherit system;
          inherit (base) specialArgs;
          modules =
            systemModules
            ++ base.sharedModules
            ++ platformModules
            ++ [
              { nixpkgs.hostPlatform = system; }
            ];
        };

      # mkContainer =
      #   {
      #     mainUser,
      #     system,
      #     systemModules ? [ ],
      #     format ? "docker",
      #   }:
      #   let
      #     base = mkBase { inherit mainUser system; };
      #   in
      #   inputs.nixos-generators.nixosGenerate {
      #     inherit system format;
      #     inherit (base) specialArgs;
      #     modules =
      #       systemModules
      #       ++ base.sharedModules
      #       ++ base.nixosModules
      #       ++ [
      #         { boot.isContainer = true; }
      #       ];
      #   };
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
          system = "x86_64-linux";
          mainUser = import ./profiles/smissingham/default.nix;
          systemModules = [
            ./hosts/coeus/configuration.nix
            ./hosting/default.nix
          ];
        };
      };

      # packages = forAllSystems (system: {
      #   thalos = mkContainer {
      #     #inherit system;
      #     system = linuxSystemFor system;
      #     mainUser = import ./profiles/smissingham/default.nix;
      #     systemModules = [
      #       ./hosts/containix/configuration.nix
      #     ];
      #   };
      # });
    };
}
