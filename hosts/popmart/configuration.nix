{
  config,
  nixpkgs,
  pkgs,
  pkgsUnstable,
  mainUser,
  ...
}:
{
  networking.hostName = "popmart";
  networking.computerName = "popmart";

  myDarwinModules = {
    #wm.sol.enable = true;
    wm.aerospace.enable = true;
  };

  #----- Nixpkgs Applications in User Space -----#
  home-manager.users.${mainUser.username}.home.packages = with pkgs; [
    obsidian
  ];
  #----- Nixpkgs Applications in System Space -----#
  environment.systemPackages = with pkgs; [
  ];

  # ----- HOMEBREW PACKAGES, MANAGED BY NIX -----#
  # ⁠SketchyBar, Borders, Dropover, Portal, Supernote, Swish, Xnip #

  homebrew = {
    casks = [

      # Browsers
      "orion"

      # Terminal
      "ghostty"

      # Workflow
      "raycast"

      # Productivity
      "microsoft-teams"
      "microsoft-excel"
      "microsoft-powerpoint"
      "microsoft-word"
      "microsoft-edge"
      "microsoft-outlook"

      # Data Science
      "knime"
      "rstudio"

      "aldente"
      "visual-studio-code"
      "gitkraken"
      "bitwarden"
      "whatsapp"
      "bartender"
      # "r" is weird, it installs and uninstalls everytime nxr is run
      "bambu-studio"
      "discord"
      "logi-options+"
      "logitune"
      "obsidian"
      "nvidia-geforce-now"
      "todoist-app"
      "windows-app"
      "onedrive"
      "chatgpt"
      "autodesk-fusion"
      "pearcleaner"

    ];

    brews = [
      "duckdb"
    ];

    # ----- MAC APP STORE APPS -----#
    masApps = {
      Xnip = 1221250572;
      Dropover = 1355679052;
    };
  };

  # https://macos-defaults.com/
  system = {

    # READ DOCS BEFORE CHANGING
    stateVersion = 5;

    defaults = {

      ".GlobalPreferences"."com.apple.mouse.scaling" = 2.5;
      spaces.spans-displays = false;

      dock = {
        autohide = false;
        show-recents = false;
        launchanim = true;
        orientation = "bottom";
        magnification = true;
        largesize = 64;
        tilesize = 48;
        expose-group-apps = true; # Group windows by application
      };

      finder = {
        _FXShowPosixPathInTitle = false;
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "Nlsv";
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        QuitMenuItem = false;
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
        AppleKeyboardUIMode = 2;
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
            "icloud_drive"
            "locations"
            "devices"
            "tags"
          ];
        };

        "com.apple.screencapture" = {
          location = "~/Documents/Screenshots";
          type = "png";
        };

        "com.apple.dock" = {
          # Disable switching workspace automatically
          workspaces-auto-swoosh = true;
          mineffect = "scale";

          # Disable workspace reordering by most-recently-used
          mru-spaces = false;
          show-recents = false;
          scroll-to-open = true;
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
