{ lib, ... }:
{
  modules.nixos.ssh =
    { config, ... }:
    let
      cfg = config.ssh;
    in
    {
      options.ssh.enable = lib.mkEnableOption "SSH server";

      config = lib.mkIf cfg.enable {
        networking.firewall.allowedTCPPorts = [ 22 ];

        services.openssh = {
          enable = true;
          ports = [ 22 ];
          settings = {
            PasswordAuthentication = true;
            AllowUsers = [ config.user.username ];
            UseDns = true;
          };
        };
      };
    };

  modules.darwin.ssh =
    { config, ... }:
    let
      cfg = config.ssh;
    in
    {
      options.ssh.enable = lib.mkEnableOption "SSH server";

      config = lib.mkIf cfg.enable {
        services.openssh.enable = true;
      };
    };
}
