{ config, lib, ... }:
{
  options = {
    flake.darwinModules = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Reusable nix-darwin modules exported by Dendritic.";
    };

    modules = {
      shared = lib.mkOption {
        type = lib.types.attrs;
        default = { };
        description = "Reusable cross-platform application modules exported by Dendritic.";
      };

      nixos = lib.mkOption {
        type = lib.types.attrs;
        default = { };
        description = "Reusable NixOS application modules exported by Dendritic.";
      };

      darwin = lib.mkOption {
        type = lib.types.attrs;
        default = { };
        description = "Reusable nix-darwin application modules exported by Dendritic.";
      };
    };
  };

  config.flake = {
    nixosModules = config.modules.shared // config.modules.nixos;
    darwinModules = config.modules.shared // config.modules.darwin;
  };
}
