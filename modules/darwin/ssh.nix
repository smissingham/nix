{
  config,
  lib,
  ...
}:

{
  # Enable macOS built-in SSH server when mySharedModules.ssh is enabled
  config = lib.mkIf config.mySharedModules.ssh.enable {
    services.openssh.enable = true;
  };
}
