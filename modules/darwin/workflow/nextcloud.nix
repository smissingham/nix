{
  config,
  lib,
  pkgs,
  mainUser,
  ...
}:
let
  moduleSet = "myDarwinModules";
  moduleCategory = "workflow";
  moduleName = "nextcloud";
  cfg = config.${moduleSet}.${moduleCategory}.${moduleName};

  ncFolders = {
    # RemotePath <=> LocalPath
    "/Documents" = "/Documents";
    "/Downloads" = "/Downloads";
    "/Pictures" = "/Pictures";
    "/Videos" = "/Videos";
  };
in
{
  options.${moduleSet}.${moduleCategory}.${moduleName} = with lib; {
    enable = mkEnableOption moduleName;
  };

  config = lib.mkIf cfg.enable {

    homebrew.casks = [ "nextcloud" ];

    home-manager.users.${mainUser.username} =
      {
        config,
        lib,
        ...
      }:
      let

        ncConfigDir = "${config.home.homeDirectory}/Library/Preferences/Nextcloud";
        ncMountDir = "${config.home.homeDirectory}/Nextcloud";
        ncConfigPath = "${ncConfigDir}/nextcloud.cfg";
        ncIgnorePath = "${ncConfigDir}/sync-exclude.lst";

        # Generate folder configurations from ncFolders attrset
        folderEntries = lib.strings.concatStringsSep "\n" (
          lib.imap1 (idx: entry: ''
            0\Folders\${toString idx}\localPath=${config.home.homeDirectory}${entry.localPath}
            0\Folders\${toString idx}\targetPath=${entry.remotePath}
          '') (lib.mapAttrsToList (remotePath: localPath: { inherit remotePath localPath; }) ncFolders)
        );

        ncConfig = ''
          [General]
          isVfsEnabled=false
          launchOnSystemStartup=true

          [Accounts]
          0\url=$(cat ${config.sops.secrets.NEXTCLOUD_URL.path})
          0\dav_user=$(cat ${config.sops.secrets.NEXTCLOUD_USERNAME.path})
          0\displayName=$(cat ${config.sops.secrets.NEXTCLOUD_USERNAME.path})
          0\webflow_user=$(cat ${config.sops.secrets.NEXTCLOUD_USERNAME.path})

          ${folderEntries}
        '';

        ncIgnore = ''
          *~
          ~$*
          .~lock.*
          ~*.tmp
          ]*.~*
          ].DS_Store
          ].Trash-*
          .fseventd
          .apdisk
          .Spotlight-V100
          .directory
          *.part
          *.filepart
          ].venv
          ]__pycache__
          ]node_modules
          ].dist
        '';

        # Generate mkdir commands for each local folder
        mkdirCommands = lib.strings.concatStringsSep "\n" (
          lib.mapAttrsToList (
            _remotePath: localPath: "mkdir -p ${config.home.homeDirectory}${localPath}"
          ) ncFolders
        );

        ncInitScript = pkgs.writeShellScript "nextcloud-init" ''
          mkdir -p ${ncMountDir}
          mkdir -p ${ncConfigDir}

          ${mkdirCommands}

          cat > "${ncConfigPath}" <<EOF
          ${ncConfig}
          EOF

          cat > "${ncIgnorePath}" <<EOF
          ${ncIgnore}
          EOF
        '';
      in
      {
        sops.secrets = {
          NEXTCLOUD_URL = { };
          NEXTCLOUD_USERNAME = { };
        };
        home.activation = {
          myActivationAction = lib.hm.dag.entryAfter [ "setupSops" ] ''
            $DRY_RUN_CMD ${ncInitScript}
          '';
        };
      };
  };
}
