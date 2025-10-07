{
  config,
  lib,
  pkgs,
  mainUser,
  ...
}:
let
  moduleSet = "myNixOSModules";
  moduleCategory = "virt";
  moduleName = "podman";

  cfg = config.${moduleSet}.${moduleCategory}.${moduleName};
in
{
  options.${moduleSet}.${moduleCategory}.${moduleName} = with lib; {
    enable = mkEnableOption moduleName;
    dockerCompat = mkOption {
      type = types.bool;
      default = true;
    };
    withCliTools = mkOption {
      type = types.bool;
      default = false;
    };
    withGuiTools = mkOption {
      type = types.bool;
      default = false;
    };
    dnsServers = mkOption {
      type = types.listOf types.str;
      default = [
        "1.1.1.1" # Cloudflare DNS
        "8.8.8.8" # Google DNS
      ];
      description = "DNS servers for containers to use";
    };
    enableAardvarkDns = mkOption {
      type = types.bool;
      default = true;
      description = "Enable aardvark-dns for container name resolution";
    };
  };

  config = lib.mkIf cfg.enable {

    users.users.${mainUser.username}.extraGroups = [ "podman" ];

    networking.firewall.interfaces."podman+".allowedUDPPorts = [
      53
      5353
    ];

    environment.variables.DOCKER_HOST = "unix:///run/user/1000/podman/podman.sock";

    # Enable common container config files in /etc/containers
    virtualisation.containers.enable = true;

    # Configure containers.conf for better DNS resolution
    virtualisation.containers.containersConf.settings = {
      network = {
        # Use netavark as network backend (modern default)
        network_backend = "netavark";
        # Configure DNS servers to avoid systemd-resolved conflicts
        dns_servers = cfg.dnsServers;
        # Enable DNS search domains
        dns_searches = [ "local" ];
      };
      containers = {
        # Ensure proper DNS configuration for containers
        dns_servers = cfg.dnsServers;
        dns_searches = [ "local" ];
        # Set default DNS options for better resolution
        dns_options = [
          "ndots:2"
          "edns0"
          "timeout:3"
          "attempts:2"
        ];
      };
    };

    virtualisation.podman = lib.mkMerge [

      {
        enable = true;
        autoPrune.enable = true;
      }

      (lib.mkIf cfg.dockerCompat {

        dockerCompat = true; # Create a `docker` alias for podman
        # Required for containers under podman-compose to be able to talk to each other.
        defaultNetwork.settings = {
          dns_enabled = true;
          # Configure DNS servers that are accessible from containers
          dns_servers = cfg.dnsServers;
          # Enable container name resolution
          internal_dns = true;
        };

        # Make the Podman socket available in place of the Docker socket, so Docker tools can find the Podman socket.
        # Users must be in the podman group in order to connect. As with Docker, members of this group can gain root access.
        dockerSocket.enable = true;

      })

    ];

    environment.systemPackages =
      with pkgs;
      lib.mkMerge [

        # Core packages for DNS resolution
        (lib.mkIf cfg.enableAardvarkDns [
          aardvark-dns # DNS server for container name resolution
          netavark # Modern container network stack
        ])

        # Optional CLI Tools
        (lib.mkIf cfg.withCliTools [
          dive # look into docker image layers
          podman-tui # podman ui in terminal
        ])

        # Optional GUI Tools
        (lib.mkIf cfg.withGuiTools [ podman-desktop ])

        # Docker Compat Packages
        (lib.mkIf cfg.dockerCompat [ podman-compose ])
      ];

    # Environment variables for better DNS resolution
    environment.variables = {
      # Help containers find the correct DNS servers
      NETAVARK_DNS_SERVERS = lib.concatStringsSep "," cfg.dnsServers;
    };

    # Simple one-shot service to restart containers with restart-policy=always after user login
    systemd.user.services.podman-restart-always = {
      enable = true;
      description = "Restart containers with restart-policy=always";

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.writeShellScript "restart-always-containers" ''
          ${pkgs.podman}/bin/podman restart $(${pkgs.podman}/bin/podman ps -q --filter 'restart-policy=always')
        ''}";
      };

      # This makes the service run after the user logs in
      wantedBy = [ "default.target" ];
    };

    # Warning for systemd-resolved users
    warnings = lib.optional (config.services.resolved.enable or false) ''
      Podman DNS may conflict with systemd-resolved. If you experience DNS issues:
      1. Consider disabling systemd-resolved stub resolver: services.resolved.llmnr = "false";
      2. Or configure systemd-resolved to use different DNS servers
      3. The current DNS servers (${lib.concatStringsSep ", " cfg.dnsServers}) should be accessible from containers
    '';
  };
}
