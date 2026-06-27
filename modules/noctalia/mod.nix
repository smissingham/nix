{ inputs, lib, ... }:
let
  noctalia = inputs.wrapper-modules.wrappers.noctalia-shell;
in
{
  modules.nixos.noctalia =
    {
      config,
      pkgs,
      ...
    }:
    let
      cfg = config.noctalia;
      package = noctalia.wrap {
        inherit pkgs;
        settings = {
          colorSchemes = {
            darkMode = true;
            predefinedScheme = "Tokyo-Night";
            useWallpaperColors = false;
          };

          appLauncher = {
            enableClipboardHistory = true;
            autoPasteClipboard = false;
            enableClipPreview = true;
            clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
            clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
          };

          general = {
            clockStyle = "custom";
            clockFormat = "ddd MMM d h:mm AP";
          };

          bar = {
            position = "top";
            displayMode = "always_visible";
            widgets = {
              left = [
                { id = "ActiveWindow"; }
              ];
              center = [
                { id = "Workspace"; }
              ];
              right = [
                {
                  id = "SystemMonitor";
                  compactMode = false;
                  showCpuUsage = true;
                  showCpuTemp = true;
                  showMemoryUsage = true;
                  showMemoryAsPercent = true;
                  showDiskUsage = true;
                  showDiskUsageAsPercent = true;
                }
                { id = "NotificationHistory"; }
                {
                  id = "Tray";
                  drawerEnabled = true;
                }
                { id = "ControlCenter"; }
                { id = "Clock"; }
              ];
            };
          };
        };
      };
    in
    {
      options.noctalia = {
        enable = lib.mkEnableOption "Noctalia shell setup";

        gtk = {
          themeName = lib.mkOption {
            type = lib.types.str;
            default = "Tokyonight-Dark";
            description = "GTK theme name used by desktop applications.";
          };

          themePackage = lib.mkOption {
            type = lib.types.package;
            default = pkgs.tokyonight-gtk-theme;
            description = "Package providing the configured GTK theme.";
          };

          textScalingFactor = lib.mkOption {
            type = lib.types.nullOr lib.types.float;
            default = null;
            description = "Optional GNOME/GTK text scaling factor for desktop applications.";
          };

          xftDpi = lib.mkOption {
            type = lib.types.nullOr lib.types.int;
            default = null;
            description = "Optional GTK Xft DPI value multiplied by 1024.";
          };
        };

        cursor = {
          name = lib.mkOption {
            type = lib.types.str;
            default = "Bibata-Modern-Ice";
            description = "Cursor theme name used by GTK and XCursor-aware Wayland applications.";
          };

          package = lib.mkOption {
            type = lib.types.package;
            default = pkgs.bibata-cursors;
            description = "Package providing the configured cursor theme.";
          };

          size = lib.mkOption {
            type = lib.types.int;
            default = 24;
            description = "Cursor size used by GTK and XCursor-aware Wayland applications.";
          };
        };
      };

      config = lib.mkIf cfg.enable {
        environment = {
          systemPackages = [
            package
            cfg.cursor.package
            cfg.gtk.themePackage
            pkgs.glib
            pkgs.gsettings-desktop-schemas
            pkgs.kdePackages.dolphin
          ];

          sessionVariables = {
            GSETTINGS_SCHEMA_DIR = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";
            GTK_THEME = cfg.gtk.themeName;
            XCURSOR_THEME = cfg.cursor.name;
            XCURSOR_SIZE = toString cfg.cursor.size;
          };

          etc = {
            "xdg/gtk-3.0/settings.ini".text = ''
              [Settings]
              gtk-application-prefer-dark-theme=1
              gtk-theme-name=${cfg.gtk.themeName}
              gtk-cursor-theme-name=${cfg.cursor.name}
              gtk-cursor-theme-size=${toString cfg.cursor.size}
              ${lib.optionalString (cfg.gtk.xftDpi != null) "gtk-xft-dpi=${toString cfg.gtk.xftDpi}"}
            '';

            "xdg/gtk-4.0/settings.ini".text = ''
              [Settings]
              gtk-application-prefer-dark-theme=1
              gtk-theme-name=${cfg.gtk.themeName}
              gtk-cursor-theme-name=${cfg.cursor.name}
              gtk-cursor-theme-size=${toString cfg.cursor.size}
              ${lib.optionalString (cfg.gtk.xftDpi != null) "gtk-xft-dpi=${toString cfg.gtk.xftDpi}"}
            '';
          };
        };

        programs.dconf = {
          enable = true;
          profiles.user.databases = [
            {
              settings."org/gnome/desktop/interface" = {
                cursor-theme = cfg.cursor.name;
                cursor-size = lib.gvariant.mkInt32 cfg.cursor.size;
                gtk-theme = cfg.gtk.themeName;
              }
              // lib.optionalAttrs (cfg.gtk.textScalingFactor != null) {
                text-scaling-factor = lib.gvariant.mkDouble cfg.gtk.textScalingFactor;
              };
            }
          ];
        };
      };
    };
}
