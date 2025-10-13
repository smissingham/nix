{
  config,
  lib,
  pkgs,
  mainUser,
  ...
}:
let
  moduleSet = "mySharedModules";
  moduleCategory = "productivity";
  moduleName = "resilio";

  cfg = config.${moduleSet}.${moduleCategory}.${moduleName};

  isDarwin = pkgs.stdenv.isDarwin;

in
{

  options.${moduleSet}.${moduleCategory}.${moduleName} = with lib; {
    enable = mkEnableOption moduleName;
    webGuiPort = mkOption {
      type = types.int;
      default = 8888;
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.enable && isDarwin) {
      homebrew.casks = [ "resilio-sync" ];
    })

    (lib.mkIf (cfg.enable && !isDarwin) {
      home-manager.users.${mainUser.username} = {
        services.rslsync = {
          enable = true;
        };
      };
    })
  ];

}
