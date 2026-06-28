flake@{ ... }:
{
  hosts.plutus = {
    system = "aarch64-darwin";
    module =
      { ... }:
      {
        imports = [
          flake.config.profiles.smissingham
          flake.config.hosts.shared
          flake.config.modules.shared.appbundles
          flake.config.modules.darwin.appbundlesHomebrew
          flake.config.modules.shared.nixbuilders
          flake.config.modules.shared.sops
          flake.config.modules.darwin.aerospace
          flake.config.modules.darwin.homebrew
          flake.config.modules.darwin.podman
          flake.config.modules.darwin.skhd
          flake.config.modules.darwin.ssh
          flake.config.modules.darwin.tailscale
        ];

        #---------- BUNDLES ----------#
        appbundles = {
          comms.enable = true;
          development.enable = true;
          entertainment.enable = true;
          productivity.enable = true;
        };

        #---------- APPLICATIONS ----------#
        podman.enable = true;
        sops.enable = true;
        ssh.enable = true;
        tailscale.enable = true;

        #---------- FEATURES ----------#
        skhd.enable = true;
        aerospace.enable = true;
        homebrewSetup.enable = true;
        nixbuilders = {
          enable = true;
          systems = [
            "aarch64-linux"
            "aarch64-darwin"
            "x86_64-darwin"
          ];
        };

        #---------- HOST IDENTITY ----------#
        networking = {
          hostName = "plutus";
          computerName = "plutus";
        };

        #---------- SYSTEM BEHAVIOR ----------#
        system = {
          keyboard = {
            enableKeyMapping = true;
            remapCapsLockToEscape = true;
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
              expose-group-apps = true;
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
                DSDontWriteNetworkStores = true;
                DSDontWriteUSBStores = true;
              };

              "com.apple.finder" = {
                _FXSortFoldersFirst = true;
                FXDefaultSearchScope = "SCcf";
                FXPreferredViewStyle = "Nlsv";
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
                workspaces-auto-swoosh = true;
                mru-spaces = false;
              };

              "com.apple.SoftwareUpdate" = {
                AutomaticCheckEnabled = true;
                ScheduleFrequency = 1;
                AutomaticDownload = 0;
                CriticalUpdateInstall = 1;
              };

              "com.apple.symbolichotkeys" = {
                AppleSymbolicHotKeys = {
                  "60".enabled = false;
                };
              };
            };
          };
        };
      };
  };
}
