{
  config,
  lib,
  pkgs,
  mainUser,
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

  config =
    let
      runtimeLinkPath = "${config.users.users.${mainUser.username}.home}/.local/share/podman";
      initScriptName = "podman-init";
      initScriptBin = pkgs.writeShellScriptBin initScriptName ''
        ${pkgs.podman}/bin/podman machine inspect podman-machine-default >/dev/null 2>&1 || \
          ${pkgs.podman}/bin/podman machine init
        ${pkgs.podman}/bin/podman machine start

        rm -rf ${runtimeLinkPath}

        RUNTIME_PATH=$(${pkgs.fd}/bin/fd "podman.*\.sock" /var/folders -x dirname | head -n1)
        ln -s $RUNTIME_PATH ${runtimeLinkPath}
      '';
    in
    lib.mkIf cfg.enable {
      mySharedModules.home.shells.aliases = lib.mkMerge [
        (lib.mkIf cfg.dockerCompat {
          docker = "podman";
        })
      ];

      environment.variables.DOCKER_HOST = "unix://${runtimeLinkPath}/podman-machine-default-api.sock";
      environment.variables.DOCKER_SOCKET = "${runtimeLinkPath}/podman-machine-default-api.sock";

      environment.systemPackages =
        with pkgs;
        lib.mkMerge [
          # Core packages
          [
            podman
            initScriptBin
          ]

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
          ProgramArguments = [ "${config.system.path}/bin/${initScriptName}" ];
          RunAtLoad = true;
          KeepAlive = false;
          StandardOutPath = "/tmp/podman-machine.log";
          StandardErrorPath = "/tmp/podman-machine.err.log";
        };
      };
    };
}
