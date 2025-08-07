{
  pkgs,
  mainUser,
  ...
}:
{
  networking.hostName = "plutus";
  networking.computerName = "plutus";

  myDarwinModules = {
    workflow.aerospace.enable = true;
  };

  mySharedModules = {
    browsers = {
      floorp.enable = true;
    };
    devtools = {
      vscode.enable = true;
      nvim-smissingham.enable = true;
    };
    workflow = {
      sops.enable = true;
    };
  };

  #----- Nixpkgs Applications in User Space -----#
  home-manager.users.${mainUser.username}.home.packages = with pkgs; [
    flameshot
    spotify
    obsidian
    gitkraken
    bruno
    gimp

    mypkgs.pfxpackage
    fswatch
  ];

  #----- Nixpkgs Applications in System Space -----#
  environment.systemPackages = with pkgs; [
    # SDK Build Packages
    nodejs_20
    uv
  ];

  # ----- HOMEBREW PACKAGES, MANAGED BY NIX -----#
  homebrew = {
    taps = [
      #"sst/tap"
    ];

    casks = [

      # ----- WORKFLOW ----- #
      "raycast"
      "filen"
      "google-chrome"
      "claude"

      # ----- MEDIA ----- #
      "stremio"
      "vlc"
      "comfyui"

      # ----- COMMUNICATIONS ----- #
      "signal"
      "legcord"

      # ----- WORK / PRODUCTIVITY ----- #
      "microsoft-teams"
      "microsoft-excel"
      "microsoft-powerpoint"
      "microsoft-word"
      "onedrive"

      # ----- OS / SYSTEM ----- #
      "ghostty"
      "onyx"
      "commander-one"
      "xquartz"

      # ----- DEV TOOLS ----- #
      "intellij-idea-ce"
      "jetbrains-toolbox"
    ];

    brews = [
      "duckdb"
      # "opencode"
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

        "com.apple.symbolichotkeys" = {
          AppleSymbolicHotKeys = {
            "60".enabled = false; # usually defaults to Ctrl-Space, conflicts with tmux
          };
        };
      };

    };

  };

}
