{
  config,
  lib,
  mainUser,
  ...
}:

let
  moduleSet = "myNixOSModules";
  moduleCategory = "access";
  moduleName = "ssh";

  cfg = config.${moduleSet}.${moduleCategory}.${moduleName};
in
{
  options.${moduleSet}.${moduleCategory}.${moduleName} = with lib; {
    enable = mkEnableOption moduleName;
    port = mkOption {
      type = types.int;
      default = 22;
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ cfg.port ];
    services.openssh = {
      enable = true;
      ports = [ cfg.port ];
      settings = {
        PasswordAuthentication = true;
        AllowUsers = [ mainUser.username ];
        UseDns = true;
      };
    };
  };
}
