{ lib, ... }:
{
  modules.nixos.podman =
    {
      config,
      pkgs,
      ...
    }:
    let
      cfg = config.podman;
      dnsServers = [
        "1.1.1.1"
        "8.8.8.8"
      ];
    in
    {
      options.podman.enable = lib.mkEnableOption "Podman setup";

      config = lib.mkIf cfg.enable {
        users.users.${config.user.username}.extraGroups = [ "podman" ];

        networking.firewall.interfaces."podman+".allowedUDPPorts = [
          53
          5353
        ];

        environment.variables = {
          DOCKER_HOST = "unix:///run/user/1000/podman/podman.sock";
          NETAVARK_DNS_SERVERS = lib.concatStringsSep "," dnsServers;
        };

        virtualisation.containers = {
          enable = true;
          containersConf.settings = {
            network = {
              network_backend = "netavark";
              dns_servers = dnsServers;
              dns_searches = [ "local" ];
            };

            containers = {
              dns_servers = dnsServers;
              dns_searches = [ "local" ];
              dns_options = [
                "ndots:2"
                "edns0"
                "timeout:3"
                "attempts:2"
              ];
            };
          };
        };

        virtualisation.podman = {
          enable = true;
          autoPrune.enable = true;
          dockerCompat = true;
          dockerSocket.enable = true;
          defaultNetwork.settings = {
            dns_enabled = true;
            dns_servers = dnsServers;
            internal_dns = true;
          };
        };

        environment.systemPackages = [
          pkgs.aardvark-dns
          pkgs.dive
          pkgs.netavark
          pkgs.podman-compose
          pkgs.podman-tui
        ];

        systemd.user.services.podman-restart-always = {
          enable = true;
          description = "Restart containers with restart-policy=always";
          wantedBy = [ "default.target" ];

          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.writeShellScript "restart-always-containers" ''
              ${pkgs.podman}/bin/podman restart $(${pkgs.podman}/bin/podman ps -q --filter 'restart-policy=always')
            ''}";
          };
        };

      };
    };

  modules.darwin.podman =
    {
      config,
      pkgs,
      ...
    }:
    let
      cfg = config.podman;
      runtimeLinkPath = "${config.user.paths.data}/podman";
      dockerCompatBin = pkgs.writeShellScriptBin "docker" ''
        exec ${pkgs.podman}/bin/podman "$@"
      '';
    in
    {
      options.podman.enable = lib.mkEnableOption "Podman setup";

      config = lib.mkIf cfg.enable {
        environment.variables = {
          DOCKER_HOST = "unix://${runtimeLinkPath}/podman-machine-default-api.sock";
          DOCKER_SOCKET = "${runtimeLinkPath}/podman-machine-default-api.sock";
          PODMAN_COMPOSE_WARNING_LOGS = "false";
        };

        environment.systemPackages = [
          pkgs.dive
          dockerCompatBin
          pkgs.podman
          pkgs.podman-compose
          pkgs.podman-tui
        ];
      };
    };
}
