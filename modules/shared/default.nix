# ----- DEFAULTS TO APPLY ON ALL (DARWIN + NIXOS) SYSTEMS -----#
{
  mainUser,
  pkgs,
  ...
}:
{
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  environment.variables = {
    NIX_CONFIG_HOME = mainUser.getNixConfPath { };
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
