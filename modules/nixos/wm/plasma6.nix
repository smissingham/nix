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

        home.packages = with pkgs; [ kdePackages.plasma-browser-integration ];

        programs.plasma = {
          enable = true;

          workspace = {
            lookAndFeel = "org.kde.breezedark.desktop";
            theme = "breeze-dark";
            colorScheme = "BreezeDark";
          };

          hotkeys.commands = {
            "launch-system-monitor" = {
              name = "Launch System Monitor";
              key = "Ctrl+Shift+Escape";
              command = "plasma-systemmonitor";
            };

            "launch-terminal" = {
              name = "Launch Terminal";
              key = "Ctrl+`";
              command = "alacritty";
            };
          };

          shortcuts = {
            "kwin"."ExposeAll" = [
              "Ctrl+F10"
              "Meta+Tab"
            ];
            "kwin"."Overview" = "Meta+W";
            "org.kde.spectacle.desktop"."RectangularRegionScreenShot" = "Print";
          };

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
                      "applications:floorp.desktop"
                      "applications:jetbrains-toolbox.desktop"
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
