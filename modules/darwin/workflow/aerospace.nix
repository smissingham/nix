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
  moduleDots = "${config.environment.variables.NIX_CONFIG_HOME}/dots/modules/${moduleCategory}/aerospace";

  optionPath = [
    moduleSet
    moduleCategory
    moduleName
  ];
  fullModuleName = lib.concatStringsSep "." optionPath;
  enablePath = optionPath ++ [ "enable" ];
in
{
  options = lib.setAttrByPath optionPath {
    enable = lib.mkEnableOption moduleName;
  };

  config = lib.mkIf (lib.getAttrFromPath enablePath config) {
    mySharedModules.workflow.shell.stowPaths = [
      "${moduleDots}"
    ];
    home-manager.users.${mainUser.username} =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        buildScriptName = "build-and-reload-aerospace";
        buildAerospaceScript = pkgs.writeShellScriptBin "${buildScriptName}" ''
          pushd "${config.xdg.configHome}/aerospace" >/dev/null;
            cat $(ls *.toml | grep -v "aerospace.toml") > aerospace.toml;
            ${pkgs.aerospace}/bin/aerospace reload-config
            ${pkgs.skhd}/bin/skhd -r
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
    };
  };
}
