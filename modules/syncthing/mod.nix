{ lib, ... }:
let
  hosts = {
    coeus = {
      id = "W5TEMWM-5XBJ2MR-FITA2KK-T5AUGIU-PUE4F6P-LXOD4QF-UDEPXLL-EEMNQA2";
      name = "coeus";
      autoAcceptFolders = true;
      introducer = true;
      folders = [
        "Documents"
        "Employer"
      ];
    };

    plutus = {
      id = "22HQZPX-QZCPEL3-7FLRYGW-H7COAYY-TJGMR2C-7HMKUK2-HKYNVEO-HTP5CAI";
      name = "plutus";
      autoAcceptFolders = true;
      folders = [
        "Documents"
        "Employer"
      ];
    };

    pixel = {
      id = "DMHANJ7-UMQ7WSM-3Z64KUK-JPXDMHM-Q3ECGIS-7ACMDOG-Z5RDTH5-YR6CRAT";
      name = "pixel";
      autoAcceptFolders = true;
      folders = [ "Documents" ];
    };
  };

  devices = lib.mapAttrs (_: host: removeAttrs host [ "folders" ]) hosts;

  ignorePatterns = [
    "result"
    "result-*"
    ".direnv"
    ".akuna/data"
    "node_modules"
    ".next"
    ".nuxt"
    ".output"
    ".svelte-kit"
    "dist"
    "build"
    ".pnpm-store"
    "bun.lockb"
    "package-lock.json"
    "yarn.lock"
    "pnpm-lock.yaml"
    "__pycache__"
    "*.pyc"
    ".pytest_cache"
    ".ruff_cache"
    ".mypy_cache"
    ".tox"
    ".venv"
    "venv"
    ".virtualenv"
    ".uv"
    "poetry.lock"
    "target"
    "Cargo.lock"
    ".cargo"
    ".rustc_info.json"
    "*.class"
    ".java-version"
    ".factorypath"
    ".project"
    ".classpath"
    ".settings"
    ".vscode"
    ".idea"
    ".fleet"
    "*.swp"
    "*.swo"
    "*~"
    ".DS_Store"
    ".Trash"
    ".Trash-*"
    ".Trashes"
    "*.log"
    "*.tmp"
    ".cache"
    ".temp"
    "tmp"
  ];

  ignoreText = lib.concatStringsSep "\n" (ignorePatterns ++ [ "" ]);
in
{
  modules.nixos.syncthing =
    { config, ... }:
    let
      cfg = config.syncthing;
      hostName = config.networking.hostName;
      host = hosts.${hostName};

      folderDeviceNames =
        folderId: builtins.attrNames (lib.filterAttrs (_: peer: builtins.elem folderId peer.folders) hosts);

      folderSettings = builtins.listToAttrs (
        map (folderId: {
          name = folderId;
          value = {
            path = "${config.user.paths.home}/${folderId}";
            id = folderId;
            devices = folderDeviceNames folderId;
          };
        }) host.folders
      );
    in
    {
      options.syncthing = {
        enable = lib.mkEnableOption "Syncthing file sync";

        cert = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "Optional Syncthing certificate path.";
        };

        key = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "Optional Syncthing key path.";
        };
      };

      config = lib.mkIf cfg.enable {
        # Syncthing does not manage .stignore through settings, so write one into each synced folder.
        system.activationScripts.syncthingStignore.text = lib.concatMapStringsSep "\n" (folderId: ''
          install -d -m 0755 -o ${config.user.username} -g users "${config.user.paths.home}/${folderId}"
          printf '%s' ${lib.escapeShellArg ignoreText} > "${config.user.paths.home}/${folderId}/.stignore"
          chown ${config.user.username}:users "${config.user.paths.home}/${folderId}/.stignore"
          chmod 0644 "${config.user.paths.home}/${folderId}/.stignore"
        '') host.folders;

        services.syncthing = {
          enable = true;
          user = config.user.username;
          dataDir = config.user.paths.home;
          configDir = "${config.user.paths.home}/.config/syncthing";
          cert = lib.mkIf (cfg.cert != null) cfg.cert;
          key = lib.mkIf (cfg.key != null) cfg.key;

          settings = {
            inherit devices;

            options = {
              globalAnnounceEnabled = true;
              urAccepted = -1;
            };

            folders = folderSettings;
          };
        };
      };
    };
}
