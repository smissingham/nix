{
  pkgs,
  mainUser,
  ...
}:
{
  networking.hostName = "plutus";
  networking.computerName = "plutus";

  myPrivateModules = {
    productivity.backup.enable = true;
    projects.pricefx-core.enable = true;
  };

  myDarwinModules = {
    workflow.aerospace.enable = true;
    virt.podman = {
      enable = true;
      withGuiTools = false;
      withCliTools = true;
    };
  };

  mySharedModules = {
    browsers = {
      floorp.enable = true;
      brave.enable = true;
    };
    devtools = {
      terminals.enable = true;
      tmux.enable = true;
      smissingham-nvim.enable = true;
      smissingham-vscode.enable = true;
    };
    productivity = {
      thunderbird.enable = false;
    };
    workflow = {
      sops.enable = true;
    };
  };

  #----- Nixpkgs Applications in User Space -----#
  home-manager.users.${mainUser.username}.home.packages = with pkgs; [
    # GUI Productivity Apps
    obsidian
    #gitkraken
    #bruno
    gimp
    #mypkgs.filen-desktop

    # CLI Stuff
    mypkgs.pfxpackage
  ];

  #----- Nixpkgs Applications in System Space -----#
  environment.systemPackages = with pkgs; [
    bun
    uv
  ];

  # ----- HOMEBREW PACKAGES, MANAGED BY NIX -----#
  homebrew = {
    taps = [
    ];

    casks = [

      # ----- WORKFLOW ----- #
      "raycast"
      # "google-chrome"
      # "shottr"

      # ----- MEDIA ----- #
      "stremio"
      "spotify"
      "vlc"
      #"obs"
      #"obs-backgroundremoval"

      # ----- COMMUNICATIONS ----- #
      "signal"
      #"legcord"

      # ----- WORK / PRODUCTIVITY ----- #
      "microsoft-teams"
      "microsoft-excel"
      "microsoft-powerpoint"
      "microsoft-word"
      "onedrive"
      "google-drive"
      "macfuse"

      # ----- OS / SYSTEM ----- #
      # "onyx"
      # "commander-one"
      # "xquartz"
      # "yubico-authenticator"
      #"parallels"

      # ----- DEV TOOLS ----- #
      "intellij-idea-ce"
      #"jetbrains-toolbox"
      "claude"
      # "cursor"
      # "visual-studio-code"

      # ----- AI TOOLS ----- #
      #"lm-studio"
      #"anythingllm"
      #"comfyui"
    ];

    brews = [
      #"duckdb"
    ];

    # ----- MAC APP STORE APPS -----#
    masApps = {
      "Xcode" = 497799835;
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
