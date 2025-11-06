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
  moduleName = "nextcloud";
  cfg = config.${moduleSet}.${moduleCategory}.${moduleName};

  isDarwin = builtins.pathExists /System/Library/CoreServices;
  isLinux = builtins.pathExists /proc/sys/kernel;
in
{
  options.${moduleSet}.${moduleCategory}.${moduleName} = with lib; {
    enable = mkEnableOption moduleName;
  };

  config =
    lib.optionalAttrs isDarwin {
      homebrew.casks = [ "nextcloud" ];
    }
    // lib.optionalAttrs isLinux {
      environment.systemPackages = [ pkgs.nextcloud-client ];
    };
}
