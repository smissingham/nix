{
  config,
  lib,
  mainUser,
  ...
}:

{
  # Enable NixOS SSH server and firewall when mySharedModules.ssh is enabled
  config = lib.mkIf config.mySharedModules.ssh.enable {
    networking.firewall.allowedTCPPorts = [ 22 ];
    services.openssh = {
      enable = true;
      ports = [ 22 ];
      settings = {
        PasswordAuthentication = true;
        AllowUsers = [ mainUser.username ];
        UseDns = true;
      };
    };
  };
}
