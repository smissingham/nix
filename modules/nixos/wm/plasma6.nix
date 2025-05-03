{
  config,
  pkgs,
  lib,
  mainUser,
  inputs,
  ...
}:
let
  moduleSet = "mySystemModules";
  moduleCategory = "wm";
  moduleName = "plasma6";

  cfg = config.${moduleSet}.${moduleCategory}.${moduleName};

  wallpaperUrl = "https://wallpaperswide.com/download/coral_reef_3-wallpaper-5120x2160.jpg";
  wallpaperSha = "sha256-AztMjrvRZtCe/MQZ5GvO/x+k/8YPmgqSu7hYt3Vlfew=";
  wallpaperImage = pkgs.fetchurl {
    url = wallpaperUrl;
    sha256 = wallpaperSha;
  };

in
{

  options.${moduleSet}.${moduleCategory}.${moduleName} = with lib; {
    enable = mkEnableOption moduleName;
  };

  config = lib.mkIf cfg.enable {

    # Enable the KDE Plasma Desktop Environment.
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;

    home-manager = {
      users.${mainUser.username} = {
        imports = [ (import "${inputs.plasma-manager}/modules") ];

        home.packages = with pkgs; [
          kdePackages.plasma-browser-integration
          kdePackages.partitionmanager

        ];

        programs.plasma = {
          enable = true;

          workspace = {
            lookAndFeel = "org.kde.breezedark.desktop";
            theme = "breeze-dark";
            colorScheme = "BreezeDark";
            wallpaper = wallpaperImage;
          };

          fonts = {
            general = {
              family = "Ubuntu Nerd Font";
              pointSize = 10;
            };
            fixedWidth = {
              family = "JetBrainsMono Nerd Font";
              pointSize = 10;
            };
            small = {
              family = "Ubuntu Nerd Font";
              pointSize = 10;
            };
            toolbar = {
              family = "Ubuntu Nerd Font";
              pointSize = 10;
            };
            menu = {
              family = "Ubuntu Nerd Font";
              pointSize = 10;
            };
            windowTitle = {
              family = "Ubuntu Nerd Font";
              pointSize = 10;
            };
          };

          kwin.virtualDesktops.names = [
            "Home Base"
            "Home Projects"
            "Work Base"
            "Work Project 1"
            "Work Project 2"
          ];

          hotkeys.commands = {
            "launch-system-monitor" = {
              name = "Launch System Monitor";
              key = "Ctrl+Shift+Escape";
              command = "plasma-systemmonitor";
            };

            "launch-terminal" = {
              name = "Launch Terminal";
              key = "Ctrl+`";
              command = mainUser.terminalApp;
            };
          };

          shortcuts = {
            "kwin"."ExposeAll" = [
              "Ctrl+F10"
              "Meta+Tab"
            ];
            "kwin"."Overview" = "Meta+W";
            "org.kde.krunner.desktop"."_launch" = "Ctrl+Space";
            "org.kde.spectacle.desktop"."RectangularRegionScreenShot" = "Print";
          };

          input.keyboard.numlockOnStartup = "on";
          input.mice = [
            {
              vendorId = "046d";
              productId = "c54d";
              name = "Logitech USB Receiver";
              acceleration = 1; # actually pointer speed, not accel
              accelerationProfile = "none"; # mouse acceleration off
            }
          ];

          panels = [
            {
              location = "right";
              height = 64;
              floating = false;
              alignment = "center";
              widgets = [
                "org.kde.plasma.panelspacer"
                {
                  iconTasks = {
                    launchers = [
                      "applications:org.kde.dolphin.desktop"
                      "applications:org.kde.konsole.desktop"
                      "applications:firefox.desktop"
                      #"applications:jetbrains-toolbox.desktop"
                    ];
                  };
                }
                "org.kde.plasma.panelspacer"
                {
                  digitalClock = {
                    date.enable = true;
                    calendar.firstDayOfWeek = "sunday";
                    date = {
                      format = "longDate";
                    };
                    time = {
                      format = "12h";
                      showSeconds = "onlyInTooltip";
                    };
                  };
                }
                {
                  systemTray.items = {
                    shown = [
                      "org.kde.plasma.bluetooth"
                      "org.kde.plasma.networkmanagement"
                      "org.kde.plasma.volume"
                    ];
                  };
                }
                {
                  name = "org.kde.plasma.kickoff";
                  config = {
                    General = {
                      #icon = builtins.fetchurl "custom-launch-icon.svg";
                      alphaSort = true;
                    };
                  };
                }
              ];
              hiding = "none";
            }
          ];

        };
      };
    };
  };
}
