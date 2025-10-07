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
      in
      {
        home = {
          packages = with pkgs; [
            aerospace
            jankyborders
            sketchybar
            skhd
            buildAerospaceScript
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
