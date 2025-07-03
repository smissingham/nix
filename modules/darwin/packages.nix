# ----- PACKAGES TO INSTALL ON ALL (DARWIN + NIXOS) SYSTEMS -----#
{ pkgs, mainUser, ... }:
{
  #----- Nixpkgs Applications in User Space -----#
  home-manager.users.${mainUser.username}.home.packages = with pkgs; [
    #appcleaner
    skhd
    aerospace
    jankyborders
    sketchybar
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
      #"arc"
      #"ferdium"
      "google-chrome"
      #"firefox"
      "raycast"
      #"alt-tab"
      #"filen"
      #"floorp"
      #"cursor"
      "ghostty"
      #"moom"
      "onyx"
      #"balenaetcher"
      "lm-studio"
      #"proton-drive"

      #"orbstack"

      "microsoft-teams"
      "microsoft-excel"
      "microsoft-powerpoint"
      "microsoft-word"
    ];

    brews = [
      "duckdb"
      "libomp"
      #"podman"
      #"podman-compose"
    ];

    onActivation = {
      cleanup = "zap";
    };

    # ----- MAC APP STORE APPS -----#
    masApps = {

    };
  };

  # In your nix-darwin configuration
  launchd.user.agents = {
    raycast = {
      serviceConfig = {
        ProgramArguments = [ "/Applications/Raycast.app/Contents/MacOS/Raycast" ];
        RunAtLoad = true;
        KeepAlive = true;
      };
    };

    skhd = {
      serviceConfig = {
        ProgramArguments = [ "${pkgs.skhd}/bin/skhd" ];
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "/tmp/skhd.log";
        StandardErrorPath = "/tmp/skhd.log";
      };
    };

    aerospace = {
      serviceConfig = {
        ProgramArguments = [ "${pkgs.aerospace}/bin/aerospace" ];
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "/tmp/aerospace.log";
        StandardErrorPath = "/tmp/aerospace.log";
      };
    };
  };
}

# ----- NOTING MANUALLY INSTALLED PACKAGES, NOT SUPPORTED BY NIX -----#
