{
  config,
  lib,
  pkgs,
  mainUser,
  ...
}:
let
  moduleSet = "myDarwinModules";
  moduleCategory = "workflow";
  moduleName = "aerospace";
  moduleDots = "${config.environment.variables.NIX_CONFIG_HOME}/modules/darwin/${moduleCategory}/dots/${moduleName}";

  optionPath = [
    moduleSet
    moduleCategory
    moduleName
  ];
  fullModuleName = lib.concatStringsSep "." optionPath;
  enablePath = optionPath ++ [ "enable" ];

  bordersConfig = [
    "style=round"
    "hidpi=on"
    "active_color=0xff00FFDE"
    "width=5.0"
  ];
in
{
  options = lib.setAttrByPath optionPath {
    enable = lib.mkEnableOption moduleName;
  };

  config = lib.mkIf (lib.getAttrFromPath enablePath config) {
    mySharedModules.home.stows = [
      "${moduleDots}"
    ];
    home-manager.users.${mainUser.username} =
      {
        lib,
        pkgs,
        ...
      }:
      let
        buildScriptName = "build-and-reload-aerospace";
        buildAerospaceScript = pkgs.writeShellScriptBin "${buildScriptName}" ''
          pushd "${moduleDots}/aerospace" >/dev/null;
            cat $(ls *.toml | grep -v "aerospace.toml") > aerospace.toml;
            
            if /usr/bin/pgrep -x AeroSpace > /dev/null; then
              ${pkgs.aerospace}/bin/aerospace reload-config
            else
              /usr/bin/open -a ${pkgs.aerospace}/Applications/AeroSpace.app
            fi
            
            /usr/bin/pkill -x skhd 2>/dev/null
            ${pkgs.skhd}/bin/skhd &
            
            /usr/bin/pkill -x borders 2>/dev/null
            ${pkgs.jankyborders}/bin/borders ${lib.concatStringsSep " " bordersConfig} &
            
            echo "Aerospace config file generated & reloaded"
          popd >/dev/null;
        '';

        # Scripts to install to system as executable binaries
        binPopCenter = pkgs.writeShellScriptBin "aerospace-pop" ''
          # Get the focused monitor info from aerospace
          MONITOR_INFO=$(aerospace list-monitors --focused)
          MONITOR_NAME=$(echo "$MONITOR_INFO" | cut -d'|' -f2 | xargs)

          # Parse out the resolution of current monitor
          MONITOR_DETAILS=$(
            system_profiler SPDisplaysDataType -json |
              jq -r ".SPDisplaysDataType[0].spdisplays_ndrvs[] | \
              select(._name == \"$MONITOR_NAME\") | \
              ._spdisplays_resolution"
          )
          MONITOR_WIDTH=$(echo "$MONITOR_DETAILS" | awk '{print $1}')
          MONITOR_HEIGHT=$(echo "$MONITOR_DETAILS" | awk '{print $3}')

          # Desired popup size, optionally accept positional args in cli
          POPUP_X_PERCENT=''${1:-50}
          POPUP_Y_PERCENT=''${2:-70}

          # Determine popup size
          popup_width=$((MONITOR_WIDTH * POPUP_X_PERCENT / 100))
          popup_height=$((MONITOR_HEIGHT * POPUP_Y_PERCENT / 100))

          # Determine popup position
          popup_x=$(((MONITOR_WIDTH - popup_width) / 2))
          popup_y=$(((MONITOR_HEIGHT - popup_height) / 2))

          # Set window to floating mode
          aerospace layout floating

          # Reposition window first
          osascript -e "tell application \"System Events\" to \
            tell (first process whose frontmost is true) to \
            set position of first window to {$popup_x, $popup_y}"

          # Resize window in new position
          osascript -e "tell application \"System Events\" to \
            tell (first process whose frontmost is true) to \
            set size of first window to {$popup_width, $popup_height}"
        '';
      in
      {
        home = {
          packages = with pkgs; [
            aerospace
            jankyborders
            sketchybar
            skhd

            buildAerospaceScript
            binPopCenter
          ];
          activation = {
            ${fullModuleName} = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
              ${buildAerospaceScript}/bin/${buildScriptName}
            '';
          };
        };
      };

    launchd.user.agents = {
      skhd = {
        serviceConfig = {
          ProgramArguments = [ "${pkgs.skhd}/bin/skhd" ];
          RunAtLoad = true;
          StandardOutPath = "/tmp/skhd.log";
          StandardErrorPath = "/tmp/skhd.log";
        };
      };
      borders = {
        serviceConfig = {
          ProgramArguments = [ "${pkgs.jankyborders}/bin/borders" ] ++ bordersConfig;
          RunAtLoad = true;
          StandardOutPath = "/tmp/borders.log";
          StandardErrorPath = "/tmp/borders.log";
        };
      };
    };
  };
}
