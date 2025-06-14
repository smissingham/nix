# ----- DEFAULTS TO APPLY ONLY ON DARWIN SYSTEMS -----#
{ mainUser, pkgs, ... }:
{
  system =
    let
      appShortcuts = {
        "New Tab" = "^t";
        "New Window" = "^n";
      };
    in
    {
      # https://macos-defaults.com/
      defaults = {

        ".GlobalPreferences"."com.apple.mouse.scaling" = 2.5;
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

        spaces.spans-displays = false;

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

      };

      keyboard = {
        enableKeyMapping = true;
        remapCapsLockToEscape = true;
        #swapLeftCommandAndLeftAlt = true;
        userKeyMapping = [
        ];
      };

      # Following line should allow us to avoid a logout/login cycle
      activationScripts.postUserActivation.text = ''
        /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
      '';

    };
}
