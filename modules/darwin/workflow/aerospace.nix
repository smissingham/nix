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
      {
        home = {
          packages = with pkgs; [
            aerospace
            jankyborders
            sketchybar
            skhd
          ];
          activation = {
            ${fullModuleName} = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
              ${pkgs.stow}/bin/stow -t "${config.xdg.configHome}" -d "${moduleDots}" -R .
              echo "Stowed dots for module ${fullModuleName}"
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
      #
      # aerospace = {
      #   serviceConfig = {
      #     ProgramArguments = [
      #       "/usr/bin/open"
      #       "-a"
      #       "${pkgs.aerospace}/Applications/AeroSpace.app"
      #     ];
      #     KeepAlive = true;
      #     StandardOutPath = "/tmp/aerospace.log";
      #     StandardErrorPath = "/tmp/aerospace.log";
      #   };
      # };

    };
  };
}
