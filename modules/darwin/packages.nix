# ----- PACKAGES TO INSTALL ON ALL (DARWIN + NIXOS) SYSTEMS -----#
{ pkgs, mainUser, ... }:
{
  #----- Nixpkgs Applications in User Space -----#
  home-manager.users.${mainUser.username}.home.packages = with pkgs; [
    appcleaner
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
      "raycast"
      "alt-tab"
      "filen"
      "cursor"
      "moom"
      "onyx"

      "microsoft-teams"
      "microsoft-excel"
      "microsoft-powerpoint"
      "microsoft-word"
    ];

    brews = [
      "duckdb"
      "libomp"
      "podman"
      "podman-compose"
    ];

    onActivation = {
      cleanup = "zap";
    };

    # ----- MAC APP STORE APPS -----#
    masApps = {

    };
  };
}

# ----- NOTING MANUALLY INSTALLED PACKAGES, NOT SUPPORTED BY NIX -----#
