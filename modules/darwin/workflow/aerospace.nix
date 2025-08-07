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
          pushd "${config.xdg.configHome}/aerospace";
            cat $(ls *.toml | grep -v "aerospace.toml") > aerospace.toml;
            ${pkgs.aerospace}/bin/aerospace reload-config
            echo "Aerospace config file generated & reloaded"
          popd;
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
          shellAliases = {

          };
          activation = {
            ${fullModuleName} = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
              ${pkgs.stow}/bin/stow -t "${config.xdg.configHome}" -d "${moduleDots}" -R .
              echo "Stowed dots for module ${fullModuleName}"
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
