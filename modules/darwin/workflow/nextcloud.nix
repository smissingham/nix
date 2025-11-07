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

        ncInitScript = pkgs.writeShellScript "nextcloud-init" ''
          mkdir -p ${ncMountDir}
          mkdir -p ${ncConfigDir}

          cat > "${ncConfigPath}" <<EOF
          [General]
          isVfsEnabled=false
          launchOnSystemStartup=true

          [Accounts]
          0\url=$(cat ${config.sops.secrets.NEXTCLOUD_URL.path})
          0\dav_user=$(cat ${config.sops.secrets.NEXTCLOUD_USERNAME.path})
          0\displayName=$(cat ${config.sops.secrets.NEXTCLOUD_USERNAME.path})
          0\webflow_user=$(cat ${config.sops.secrets.NEXTCLOUD_USERNAME.path})

          0\Folders\1\localPath=${ncMountDir}
          0\Folders\1\targetPath=/
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
