{
  config,
  nixpkgs,
  pkgs,
  pkgsUnstable,
  mainUser,
  ...
}:
{
  networking.hostName = "plutus";
  networking.computerName = "plutus";

  myHomeModules = {
    browsers = {
      floorp.enable = true;
    };
    devtools = {
      vscode.enable = true;
    };
  };

  myDarwinModules = {
    #wm.sol.enable = true;
    workflow.aerospace.enable = true;
  };

  #----- Nixpkgs Applications in User Space -----#
  home-manager.users.${mainUser.username}.home.packages = with pkgs; [
    flameshot
    qbittorrent

    spotify
    #telegram-desktop
    obsidian
    pkgsUnstable.zed-editor
    gitkraken
    bruno
    gimp
    scrcpy

  ];
  #----- Nixpkgs Applications in System Space -----#
  environment.systemPackages = with pkgs; [
  ];

  # ----- HOMEBREW PACKAGES, MANAGED BY NIX -----#
  homebrew = {
    taps = [
      "sst/tap"
    ];
    casks = [
      "raycast"
      "filen"
      "google-chrome"
      "ghostty"
      "onyx"
      "stremio"
      "commander-one"
      "vlc"

      "microsoft-teams"
      "microsoft-excel"
      "microsoft-powerpoint"
      "microsoft-word"
      "onedrive"

      "intellij-idea-ce"
    ];

    brews = [
      "duckdb"
      "opencode"
    ];

    # ----- MAC APP STORE APPS -----#
    masApps = {
    };
  };

  # https://macos-defaults.com/
  system = {

    # READ DOCS BEFORE CHANGING
    stateVersion = 5;

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
      #swapLeftCommandAndLeftAlt = true;
      userKeyMapping = [
      ];
    };

    defaults = {

      ".GlobalPreferences"."com.apple.mouse.scaling" = 2.5;
      spaces.spans-displays = false;

      dock = {
        autohide = true;
        show-recents = false;
        launchanim = true;
        orientation = "right";
        magnification = true;
        largesize = 64;
        tilesize = 48;
        expose-group-apps = true; # Group windows by application
      };

      finder = {
        _FXShowPosixPathInTitle = true;
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "Nlsv";
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        QuitMenuItem = true;
        ShowStatusBar = true;
        ShowPathbar = true;
      };

      NSGlobalDomain = {
        AppleICUForce24HourTime = false;
        AppleInterfaceStyle = "Dark";
        AppleInterfaceStyleSwitchesAutomatically = false;
        AppleMeasurementUnits = "Centimeters";
        AppleMetricUnits = 1;
        AppleTemperatureUnit = "Celsius";
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = true;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
      };

      CustomUserPreferences = {

        NSGlobalDomain = {
          #NSUserKeyEquivalents = appShortcuts;
        };

        "com.apple.desktopservices" = {
          # Avoid creating .DS_Store files on network or USB volumes
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };

        "com.apple.finder" = {
          _FXSortFoldersFirst = true;
          FXDefaultSearchScope = "SCcf"; # Search current folder by default
          FXPreferredViewStyle = "Nlsv"; # Default to list view
          SidebarZoneOrder1 = [
            "favorites"
            "devices"
            "locations"
            "tags"
            "icloud_drive"
          ];
        };

        "com.apple.screencapture" = {
          location = "~/Documents/Screenshots";
          type = "png";
        };

        "com.apple.dock" = {
          # Disable switching workspace automatically
          workspaces-auto-swoosh = true;

          # Disable workspace reordering by most-recently-used
          mru-spaces = false;
        };

        "com.apple.SoftwareUpdate" = {
          AutomaticCheckEnabled = true;
          # Check for software updates daily, not just once per week
          ScheduleFrequency = 1;
          # Download newly available updates in background
          AutomaticDownload = 0;
          # Install System data files & security updates
          CriticalUpdateInstall = 1;
        };
      };

    };

  };

}
