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

  nix = {
    optimise = {
      automatic = true;
    };
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };
}
