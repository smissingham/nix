{
  config,
  pkgs,
  environment,
  ...
}:
{
  # ----------- Filen AutoStart on Logon ----------- #
  systemd.user.services.filen-desktop = {
    description = "Start Filen Desktop Client";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    startLimitBurst = 5;
    startLimitIntervalSec = 500;
    serviceConfig = {
      ExecStart = "${pkgs.filen-desktop}/bin/filen-desktop";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}
