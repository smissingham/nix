{
  config,
  lib,
  pkgs,
  mainUser,
  ...
}:
let
  moduleSet = "mySystemModules";
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
  };

  config = lib.mkIf cfg.enable {

    users.users.${mainUser.username}.extraGroups = [ "podman" ];

    networking.firewall.interfaces."podman+".allowedUDPPorts = [
      53
      5353
    ];

    # Enable common container config files in /etc/containers
    virtualisation.containers.enable = true;
    virtualisation.podman = lib.mkMerge [

      ({
        enable = true;
        autoPrune.enable = true;
      })

      (lib.mkIf cfg.dockerCompat {

        dockerCompat = true; # Create a `docker` alias for podman
        # Required for containers under podman-compose to be able to talk to each other.
        defaultNetwork.settings.dns_enabled = true;

        # Make the Podman socket available in place of the Docker socket, so Docker tools can find the Podman socket.
        # Users must be in the podman group in order to connect. As with Docker, members of this group can gain root access.
        dockerSocket.enable = true;

      })

    ];

    environment.systemPackages =
      with pkgs;
      lib.mkMerge [

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
  };
}
