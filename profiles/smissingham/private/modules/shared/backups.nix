{
  config,
  pkgs,
  lib,
  mainUser,
  ...
}:
let
  moduleSet = "myPrivateModules";
  moduleCategory = "productivity";
  moduleName = "backup";

  cfg = config.${moduleSet}.${moduleCategory}.${moduleName};
in
{
  options.${moduleSet}.${moduleCategory}.${moduleName} = with lib; {
    enable = mkEnableOption moduleName;
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      fuse
      fswatch
    ];

    # homebrew.casks = lib.optionalAttrs pkgs.stdenv.isDarwin [
    #   "macfuse"
    # ];

    home-manager.users.${mainUser.username} =
      {
        config,
        lib,
        ...
      }:
      let
        baseMountPath = "${config.home.homeDirectory}/fusemnt";

        # Custom variable where I manage remotes, and common settings
        remotes = {
          amat_box = {
            mount = true;
            mountOptions = {
              vfs-cache-mode = "full";
              poll-interval = "15m";
            };
            rclone = {
              config = {
                type = "box";
                box_sub_type = "enterprise";
              };
              secrets = {
                auth_url = config.sops.secrets.AMAT_BOX_AUTH_URL.path;
                token_url = config.sops.secrets.AMAT_BOX_TOKEN_URL.path;
                token = config.sops.secrets.AMAT_BOX_TOKEN.path;
              };
            };
          };

          pfx_gdrive = {
            mount = true;
            mountOptions = {
              vfs-cache-mode = "full";
              poll-interval = "15m";
            };
            rclone = {
              config = {
                type = "drive";
                scope = "drive";
                team_drive = "";
              };
              secrets = {
                client_id = config.sops.secrets.PFX_GAPPS_CLIENT_ID.path;
                client_secret = config.sops.secrets.PFX_GAPPS_CLIENT_SECRET.path;
                token = config.sops.secrets.PFX_GAPPS_TOKEN.path;
              };
            };
          };
        };

        # A function to parse the above block to the format required by home manager rclone
        rcloneRemotes = lib.mapAttrs (name: remote: {
          config = remote.rclone.config;
          secrets = remote.rclone.secrets;

          # This only applies on Linux. MacOS has custom handling below
          mounts = lib.optionalAttrs remote.mount {
            "/" = {
              enable = true;
              mountPoint = "${baseMountPath}/${name}";
              options = remote.mountOptions;
            };
          };
        }) remotes;

      in
      {

        # Set up rclone to handle remote connection, and optional fuse mounts
        programs.rclone = {
          enable = true;
          remotes = rcloneRemotes;
        };

        # Secrets required by remotes
        sops.secrets = {
          AMAT_BOX_AUTH_URL = { };
          AMAT_BOX_TOKEN_URL = { };
          AMAT_BOX_TOKEN = { };
          PFX_GAPPS_CLIENT_ID = { };
          PFX_GAPPS_CLIENT_SECRET = { };
          PFX_GAPPS_TOKEN = { };
        };

        # Ensure fuse mount directories exist for rclone to mount to
        home.activation.createFuseMountDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          mkdir -p ${baseMountPath}
          ${lib.concatMapStringsSep "\n" (name: ''
            mkdir -p ${baseMountPath}/${name}
          '') (lib.attrNames (lib.filterAttrs (_: r: r.mount) remotes))}
        '';
      }

      # MacOS requires the mounts to be set up as LaunchD Agents
      // lib.optionalAttrs pkgs.stdenv.isDarwin {
        launchd.agents = lib.mapAttrs' (
          name: remote:
          lib.nameValuePair "rclone-mount-${name}" {
            enable = remote.mount;
            config = {
              ProgramArguments = [
                "${pkgs.rclone}/bin/rclone"
                "mount"
                "${name}:/"
                "${baseMountPath}/${name}"
              ]
              ++ lib.mapAttrsToList (k: v: "--${k}=${v}") remote.mountOptions;
              KeepAlive = true;
              RunAtLoad = true;
            };
          }
        ) remotes;
      };
  };
}
