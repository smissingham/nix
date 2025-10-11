{
  config,
  lib,
  pkgs,
  ...
}:
let
  moduleSet = "myDarwinModules";
  moduleCategory = "virt";
  moduleName = "podman";

  cfg = config.${moduleSet}.${moduleCategory}.${moduleName};
in
{
  options.${moduleSet}.${moduleCategory}.${moduleName} = with lib; {
    enable = mkEnableOption moduleName;
    dockerCompat = mkOption {
      type = types.bool;
      default = true;
    };
    withCliTools = mkOption {
      type = types.bool;
      default = false;
    };
    withGuiTools = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {

    mySharedModules.home.shells.aliases = lib.mkMerge [
      (lib.mkIf cfg.dockerCompat {
        docker = "podman";
      })
    ];

    environment.systemPackages =
      with pkgs;
      lib.mkMerge [
        # Core packages
        [ podman ]

        # Optional CLI Tools
        (lib.mkIf cfg.withCliTools [
          dive # look into docker image layers
          podman-tui # podman ui in terminal
        ])

        # Optional GUI Tools
        (lib.mkIf cfg.withGuiTools [ podman-desktop ])

        # Docker Compat Packages
        (lib.mkIf cfg.dockerCompat [ podman-compose ])
      ];

    # Launch podman machine on system start
    launchd.user.agents.podman-machine = {
      serviceConfig = {
        ProgramArguments = [
          "${pkgs.writeShellScript "podman-machine-start" ''
            ${pkgs.podman}/bin/podman machine inspect podman-machine-default >/dev/null 2>&1 || \
              ${pkgs.podman}/bin/podman machine init
            ${pkgs.podman}/bin/podman machine start
          ''}"
        ];
        RunAtLoad = true;
        KeepAlive = false;
      };
    };
  };
}
