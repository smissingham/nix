{
  config,
  lib,
  pkgs,
  ...
}:

let
  moduleSet = "mySystemModules";
  moduleCategory = "access";
  moduleName = "tailscale";

  cfg = config.${moduleSet}.${moduleCategory}.${moduleName};
in
{
  options.${moduleSet}.${moduleCategory}.${moduleName} = with lib; {
    enable = mkEnableOption moduleName;
    authKey = mkOption {
      description = ''
        Required! Auth key obtained from the tailscale admin panel
        https://login.tailscale.com/admin/settings/keys
        Reference: https://tailscale.com/kb/1096/nixos-minecraft
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.tailscale.enable = true;

    # reading https://github.com/tailscale/tailscale/issues/4254
    services.resolved.enable = true;
    #networking.useNetworkd = true;
    networking.interfaces.tailscale0.useDHCP = lib.mkForce false;

    # always allow traffic from your Tailscale network
    networking.firewall.trustedInterfaces = [ "tailscale0" ];

    # allow the Tailscale UDP port through the firewall
    networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];

    # create a oneshot job to authenticate to Tailscale
    systemd.services.tailscale-autoconnect = {
      description = "Automatic connection to Tailscale";

      # make sure tailscale is running before trying to connect to tailscale
      after = [
        "network-pre.target"
        "tailscale.service"
      ];
      wants = [
        "network-pre.target"
        "tailscale.service"
      ];
      wantedBy = [ "multi-user.target" ];

      # set this service as a oneshot job
      serviceConfig.Type = "oneshot";

      # have the job run this shell script
      script = with pkgs; ''
        # wait for tailscaled to settle
        sleep 2

        # check if we are already authenticated to tailscale
        status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
        if [ $status = "Running" ]; then # if so, then do nothing
          exit 0
        fi

        # otherwise authenticate with tailscale
        ${tailscale}/bin/tailscale up -authkey ${cfg.authKey}
      '';
    };
  };
}
