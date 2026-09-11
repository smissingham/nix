{ lib, ... }:
{
  modules.nixos.firewall =
    { config, ... }:
    let
      cfg = config.firewall;
    in
    {
      options.firewall.allowedTCPPorts = lib.mkOption {
        type = lib.types.listOf lib.types.port;
        default = [ ];
        description = "TCP ports to allow through the host firewall.";
      };

      config.networking.firewall.allowedTCPPorts = cfg.allowedTCPPorts;
    };

  modules.darwin.firewall =
    { config, ... }:
    let
      cfg = config.firewall;
      anchorText =
        cfg.allowedTCPPorts
        |> map (port: ''
          pass in proto tcp from 192.168.0.0/16 to any port ${toString port}
          pass in proto tcp from 10.0.0.0/8 to any port ${toString port}
          pass in proto tcp from 172.16.0.0/12 to any port ${toString port}
        '')
        |> lib.concatStringsSep "\n";
    in
    {
      options.firewall.allowedTCPPorts = lib.mkOption {
        type = lib.types.listOf lib.types.port;
        default = [ ];
        description = "TCP ports to allow through the host firewall.";
      };

      config = lib.mkIf (cfg.allowedTCPPorts != [ ]) {
        environment.etc."pf.anchors/nix-firewall".text = anchorText;

        system.activationScripts.extraActivation.text = lib.mkAfter ''
          if ! /usr/bin/grep -q 'anchor "nix-firewall"' /etc/pf.conf; then
            /usr/bin/printf '\nanchor "nix-firewall"\nload anchor "nix-firewall" from "/etc/pf.anchors/nix-firewall"\n' >> /etc/pf.conf
          fi

          /sbin/pfctl -q -a nix-firewall -f /etc/pf.anchors/nix-firewall 2>/dev/null
          /sbin/pfctl -s info 2>/dev/null | /usr/bin/grep -q '^Status: Enabled' || /sbin/pfctl -E >/dev/null 2>/dev/null
        '';
      };
    };
}
