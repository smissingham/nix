{ lib, ... }:
{
  modules.nixos.sunshine =
    { config, pkgs, ... }:
    let
      cfg = config.sunshine;
    in
    {
      options.sunshine = {
        enable = lib.mkEnableOption "Sunshine game stream host";

        withMoonlight = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Install Moonlight client alongside Sunshine.";
        };
      };

      config = lib.mkIf cfg.enable {
        environment.systemPackages = [
          pkgs.sunshine
        ]
        ++ lib.optionals cfg.withMoonlight [ pkgs.moonlight-qt ];

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
    };
}
