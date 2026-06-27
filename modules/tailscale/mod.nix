{ lib, ... }:
{
  modules.nixos.tailscale =
    {
      config,
      pkgs,
      ...
    }:
    let
      cfg = config.tailscale;
    in
    {
      options.tailscale.enable = lib.mkEnableOption "Tailscale setup";

      config = lib.mkIf cfg.enable {
        services.tailscale = {
          enable = true;
          package = pkgs.tailscale;
        };

        services.resolved.enable = true;
        networking.interfaces.tailscale0.useDHCP = lib.mkForce false;
        networking.firewall = {
          trustedInterfaces = [ "tailscale0" ];
          allowedUDPPorts = [ config.services.tailscale.port ];
        };
      };
    };

  modules.darwin.tailscale =
    {
      config,
      pkgs,
      ...
    }:
    let
      cfg = config.tailscale;
    in
    {
      options.tailscale.enable = lib.mkEnableOption "Tailscale setup";

      config = lib.mkIf cfg.enable {
        environment.systemPackages = [
          pkgs.tailscale
          pkgs.tailscale-gui
        ];
      };
    };
}
