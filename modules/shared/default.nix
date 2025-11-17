# ----- DEFAULTS TO APPLY ON ALL (DARWIN + NIXOS) SYSTEMS -----#
{
  config,
  mainUser,
  pkgs,
  ...
}:
{
  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
  };

  environment.variables = {
    NIX_CONFIG_HOME = mainUser.getNixConfPath { };
    HOSTNAME = config.networking.hostName;
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

  #----- Fonts Available to System -----#
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.ubuntu
    font-awesome
  ];

  #----- Applications in System Space -----#
  environment.systemPackages = with pkgs; [
    # General CLI Utils
    lsof
    jq

    # Nix CLI Utils
    nixfmt-rfc-style # formatter
    nixd # lsp
  ];
}
