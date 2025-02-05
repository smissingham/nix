# ----- DEFAULTS TO APPLY ON ALL (DARWIN + NIXOS) SYSTEMS -----#
{ mainUser, pkgs, ... }:
{
  imports = [
    ./home.nix
    ./packages.nix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
      packageOverrides = pkgs: {
        filen-desktop = pkgs.callPackage ../../packages/filen-desktop/package.appimage.nix { };
      };
    };
  };

  environment.variables = {
    NIX_CONFIG_HOME =
      (if pkgs.stdenv.isDarwin then "/Users/" else "/home/") + mainUser.username + "/Documents/Nix";
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
