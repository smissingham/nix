{
  config,
  lib,
  ...
}:
let
  moduleSet = "myDarwinModules";
  moduleCategory = "wm";
  moduleName = "sol";

  cfg = config.${moduleSet}.${moduleCategory}.${moduleName};
in
{
  options.${moduleSet}.${moduleCategory}.${moduleName} = with lib; {
    enable = mkEnableOption moduleName;
  };

  config = lib.mkIf cfg.enable {
    homebrew.casks = [
      "sol"
    ];

    launchd.user.agents = {
      sol = {
        serviceConfig = {
          ProgramArguments = [ "/Applications/Sol.app" ];
          RunAtLoad = true;
          KeepAlive = true;
        };
      };
    };
  };
}
