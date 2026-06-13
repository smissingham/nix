# ----- DEFAULTS TO APPLY ON ALL (DARWIN + NIXOS) SYSTEMS -----#
{
  config,
  mainUser,
  pkgs,
  dendritic,
  ...
}:
{
  programs.zsh.enable = true;

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
  };

  environment.variables = {
    NIX_CONFIG_HOME = "${
      (if pkgs.stdenv.isDarwin then "/Users" else "/home")
    }/${mainUser.username}/Documents/Nix";
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
  environment.systemPackages = [
    dendritic.sm-bundle-devtools
    pkgs.vim
  ];
}
