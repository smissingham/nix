{
  config,
  lib,
  pkgs,
  mainUser,
  ...
}:

let
  moduleSet = "myNixOSModules";
  moduleCategory = "access";
  moduleName = "fail2ban";

  cfg = config.${moduleSet}.${moduleCategory}.${moduleName};
in
{
  options.${moduleSet}.${moduleCategory}.${moduleName} = with lib; {
    enable = mkEnableOption moduleName;
  };

  config = lib.mkIf cfg.enable {

    services.fail2ban = {
      enable = true;
      maxretry = 5;
      ignoreIP = [
        # Whitelist
        "plutus"
      ];
      bantime = "24h"; # Ban IPs for one day on the first ban
      bantime-increment = {
        enable = true; # Enable increment of bantime after each violation
        formula = "ban.Time * math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)";
        #multipliers = "1 2 4 8 16 32 64";
        #maxtime = "168h"; # Do not ban for more than 1 week
        overalljails = true; # Calculate the bantime based on all the violations
      };
    };

  };
}
