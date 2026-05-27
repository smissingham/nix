{
  pkgs,
  mainUser,
  ...
}:
{
  networking.hostName = "plutus";
  networking.computerName = "plutus";

  myPrivateModules = {
    backup.syncthing.enable = true;
  };

  myDarwinModules = {
    workflow = {
      aerospace.enable = true;
    };
    virt.podman = {
      enable = true;
      withGuiTools = false;
      withCliTools = true;
    };
  };

  mySharedModules = {
    ssh.enable = true;
    browsers.brave.enable = true;
    workflow = {
      sops.enable = true;
      builders = {
        enable = true;
        systems = [
          "aarch64-darwin"
          "x86_64-darwin"
        ];
      };
    };
  };

  #----- Nixpkgs Applications in User Space -----#
  home-manager.users.${mainUser.username} =
    { ... }:
    {
      home.packages = with pkgs; [
        obsidian
        moonlight-qt
        jetbrains-toolbox
        mynixpkgs.filen-desktop
      ];
    };

  #----- Nixpkgs Applications in System Space -----#
  environment.systemPackages = [
  ];

  # ----- HOMEBREW PACKAGES, MANAGED BY NIX -----#
  homebrew = {
    taps = [
      "peteonrails/voxtype"
    ];

    casks = [

      # ----- WORKFLOW ----- #
      "raycast"
      "ghostty"
      "protonvpn"
      "voxtype"

      # ----- MEDIA ----- #
      "stremio"
      "spotify"
      "vlc"
      "obs"
      "inkscape"
      "gimp"

      # ----- COMMUNICATIONS ----- #
      "signal"

      # ----- WORK / PRODUCTIVITY ----- #
      "microsoft-teams"
      "microsoft-excel"
      "microsoft-powerpoint"
      "microsoft-word"
      "onedrive"
      "libreoffice"

      # ----- OS / SYSTEM ----- #
      "onyx"
      # "yubico-authenticator"
      # "parallels"
    ];

    brews = [
      #"duckdb"
    ];

    # ----- MAC APP STORE APPS -----#
    masApps = {
      #"Xcode" = 497799835;
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
