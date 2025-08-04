{
  config,
  lib,
  pkgs,
  ...
}:

let
  moduleSet = "myNixOSModules";
  moduleCategory = "access";
  moduleName = "sunshine";

  cfg = config.${moduleSet}.${moduleCategory}.${moduleName};
in
{
  options.${moduleSet}.${moduleCategory}.${moduleName} = with lib; {
    enable = mkEnableOption moduleName;
    withMoonlight = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages =
      with pkgs;
      lib.mkMerge [

        # Always install packages
        ([ sunshine ])

        # Optional GUI Tools
        (lib.mkIf cfg.withMoonlight [ moonlight-qt ])
      ];

    networking.firewall.allowedTCPPortRanges = [
      {
        from = 47984;
        to = 48010;
      }
    ];
    networking.firewall.allowedUDPPortRanges = [
      {
        from = 47998;
        to = 48010;
      }
    ];
    security.wrappers.sunshine = {
      owner = "root";
      group = "root";
      capabilities = "cap_sys_admin+p";
      source = "${pkgs.sunshine}/bin/sunshine";
    };
    systemd.user.services.sunshine = {
      description = "Sunshine self-hosted game stream host for Moonlight";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      startLimitBurst = 5;
      startLimitIntervalSec = 500;
      serviceConfig = {
        ExecStart = "${config.security.wrapperDir}/sunshine";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  };
}
