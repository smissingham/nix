{ lib, pkgs }:

with lib;
let
  mkCrossPlatformService =
    name: svcCfg:
    if pkgs.stdenv.isDarwin then
      {
        launchd.daemons.${name} = {
          serviceConfig = {
            ProgramArguments = svcCfg.execStart;
            KeepAlive =
              if svcCfg.restart or "on-failure" == "always" || svcCfg.restart or "on-failure" == "on-failure" then
                true
              else
                (svcCfg.wantedBy or [ "default.target" ]) != [ ];
            RunAtLoad = (svcCfg.wantedBy or [ "default.target" ]) != [ ];
            WorkingDirectory = mkIf ((svcCfg.workingDirectory or null) != null) svcCfg.workingDirectory;
            EnvironmentVariables = svcCfg.environment or { };
            StandardOutPath = mkIf ((svcCfg.standardOutput or null) != null) (
              if svcCfg.standardOutput == "journal" then "/var/log/${name}.log" else svcCfg.standardOutput
            );
            StandardErrorPath = mkIf ((svcCfg.standardError or null) != null) (
              if svcCfg.standardError == "journal" then "/var/log/${name}.error.log" else svcCfg.standardError
            );
          };
        };
      }
    else
      {
        systemd.services.${name} = {
          description = svcCfg.description or "Service ${name}";
          after = svcCfg.after or [ ];
          wantedBy = svcCfg.wantedBy or [ "default.target" ];
          serviceConfig = {
            Type = mkIf ((svcCfg.serviceType or null) != null) svcCfg.serviceType;
            ExecStart = concatStringsSep " " svcCfg.execStart;
            WorkingDirectory = mkIf ((svcCfg.workingDirectory or null) != null) svcCfg.workingDirectory;
            Environment = mapAttrsToList (k: v: "${k}=${v}") (svcCfg.environment or { });
            Restart = svcCfg.restart or "on-failure";
            RestartSec = mkIf ((svcCfg.restartSec or null) != null) svcCfg.restartSec;
            StandardOutput = mkIf ((svcCfg.standardOutput or null) != null) svcCfg.standardOutput;
            StandardError = mkIf ((svcCfg.standardError or null) != null) svcCfg.standardError;
          };
        };
      };
in
{
  inherit mkCrossPlatformService;
  mkCrossPlatformServices = services: mkMerge (mapAttrsToList mkCrossPlatformService services);
}
