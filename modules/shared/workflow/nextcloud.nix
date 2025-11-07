{
  config,
  lib,
  pkgs,
  mainUser,
  ...
}:
let
  moduleSet = "mySharedModules";
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

  # !!!!!NOTE!!!!!: This only sets the config. The platform-specific client must be installed manually
  config = lib.mkIf cfg.enable {
    home-manager.users.${mainUser.username} =
      {
        config,
        lib,
        ...
      }:
      let
        ncConfigDir =
          if pkgs.stdenv.isDarwin then
            "${config.home.homeDirectory}/Library/Preferences/Nextcloud"
          else
            "${config.home.homeDirectory}/.config/Nextcloud";
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
          # General - Temporary & Lock Files
          *~
          ~$*
          .~lock.*
          ~*.tmp
          ]*.~*
          .directory
          *.part
          *.filepart

          # macOS - System Files
          ].DS_Store
          ].Trash-*
          .fseventd
          .apdisk
          .Spotlight-V100
          ].TemporaryItems
          ].DocumentRevisions-V100
          ].fseventsd
          ].VolumeIcon.icns
          .AppleDouble
          .LSOverride

          # Linux - System Files
          ].Trash-*
          .directory
          ].nfs*

          # Python
          ]__pycache__
          ].pytest_cache
          ].mypy_cache
          ].ruff_cache
          ].pyright_cache
          ].venv
          ]venv
          *.pyc
          *.pyo
          *.pyd
          .Python
          ]pip-log.txt
          ]pip-delete-this-directory.txt
          ].tox
          ].coverage
          ].hypothesis
          ]*.egg-info
          ]dist
          ]build
          ].eggs
          ].uv
          ].poetry

          # Node/Bun
          ]node_modules
          ].npm
          ].yarn
          ].pnp
          .pnp.js
          ].next
          ].nuxt
          ].cache
          ].parcel-cache
          ].vite
          ].turbo
          ].vercel

          # Rust
          ]target
          ]Cargo.lock
          **/*.rs.bk
          *.pdb

          # Nix
          ].direnv
          ]result
          ]result-*

          # Java
          ].gradle
          ].m2
          *.class
          *.jar

          # IDE/Editor
          ].idea
          ].vscode
          *.swp
          *.swo
          *.swn
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
