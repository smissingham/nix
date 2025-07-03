{
  config,
  lib,
  pkgs,
  ...
}:

let
  moduleSet = "myDarwinModules";
  moduleCategory = "access";
  moduleName = "tailscale";

  cfg = config.${moduleSet}.${moduleCategory}.${moduleName};
in
{
  options.${moduleSet}.${moduleCategory}.${moduleName} = with lib; {
    enable = mkEnableOption moduleName;
  };

  config = lib.mkIf cfg.enable {

    homebrew = {
      casks = [
        "tailscale"
      ];
    };

    launchd.user.agents = {
      tailscale = {
        serviceConfig = {
          ProgramArguments = [ "/opt/homebrew/bin/tailscale" ];
          RunAtLoad = true;
          KeepAlive = true;
        };
      };
    };

  };
}
