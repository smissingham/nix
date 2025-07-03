{
  config,
  nixpkgs,
  pkgs,
  mainUser,
  ...
}:
{
  networking.hostName = "plutus";
  networking.computerName = "plutus";

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  myDarwinModules = {
    #access.tailscale.enable = true;
    wm.sol.enable = true;
    wm.aerospace.enable = true;
  };

  #----- Nixpkgs Applications in User Space -----#
  home-manager.users.${mainUser.username}.home.packages = with pkgs; [
    #appcleaner
    skhd
    flameshot
  ];
  #----- Nixpkgs Applications in System Space -----#
  environment.systemPackages = with pkgs; [

  ];

  # ----- HOMEBREW PACKAGES, MANAGED BY NIX -----#
  homebrew = {
    enable = true;
    taps = [
      "homebrew/core"
      "homebrew/cask"
      "homebrew/bundle"
    ];

    casks = [
      "google-chrome"
      "ghostty"
      "onyx"
      "lm-studio"

      "microsoft-teams"
      "microsoft-excel"
      "microsoft-powerpoint"
      "microsoft-word"
    ];

    brews = [
      "duckdb"
      "libomp"
    ];

    onActivation = {
      cleanup = "zap";
    };

    # ----- MAC APP STORE APPS -----#
    masApps = {

    };
  };
}
