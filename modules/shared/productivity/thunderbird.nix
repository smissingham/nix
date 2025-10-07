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
  moduleName = "thunderbird";

  cfg = config.${moduleSet}.${moduleCategory}.${moduleName};

  # Provider-specific server configurations
  providerConfigs = {
    proton = {
      flavor = "plain";
      imap = {
        host = "127.0.0.1";
        port = 1143;
        tls.enable = false;
      };
      smtp = {
        host = "127.0.0.1";
        port = 1025;
        tls.enable = false;
      };
    };
    microsoft365 = {
      flavor = "outlook.office365.com";
    };
    gmail = {
      flavor = "gmail.com";
    };
  };

  getProviderConfig =
    type:
    if builtins.hasAttr type providerConfigs then
      providerConfigs.${type}
    else
      throw "Unknown email provider type: ${type}. Supported types: ${builtins.concatStringsSep ", " (builtins.attrNames providerConfigs)}";
in
{

  options.${moduleSet}.${moduleCategory}.${moduleName} = with lib; {
    enable = mkEnableOption moduleName;
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${mainUser.username} =
      { config, lib, ... }:
      lib.mkMerge [
        {
          accounts.email.accounts = builtins.listToAttrs (
            lib.imap0 (
              index: account:
              let
                providerConfig = getProviderConfig account.type;
              in
              {
                name = account.name;
                value = {
                  primary = index == 0;
                  address = account.address;
                  realName = account.realName;
                  userName = account.address;
                  flavor = providerConfig.flavor;
                }
                // lib.optionalAttrs (providerConfig ? imap) {
                  imap = providerConfig.imap;
                }
                // lib.optionalAttrs (providerConfig ? smtp) {
                  smtp = providerConfig.smtp;
                }
                // {
                  thunderbird = {
                    enable = true;
                    profiles = [ mainUser.username ];
                  };
                };
              }
            ) mainUser.emailAccounts
          );

          programs.thunderbird = {
            enable = true;
            profiles.${mainUser.username} = {
              isDefault = true;
              settings = {
                "mail.smtpserver.default.authMethod" = 10;
                "mail.server.default.authMethod" = 10;
              };
            };
          };
          home.activation.thunderbirdSymlink = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
            THUNDERBIRD_DIR="${config.home.homeDirectory}/Library/Thunderbird"
            DATA_DIR="${config.home.homeDirectory}/Data/Thunderbird"

            # Check if symlink is already correct
            if [ -L "$THUNDERBIRD_DIR" ] && [ "$(readlink "$THUNDERBIRD_DIR")" = "$DATA_DIR" ]; then
              exit 0
            fi

            # Make sure the data destination path exists
            mkdir -p "$DATA_DIR"

            # If data dir is empty, and thunderbird dir is not, and is not a symlink, move contents
            if [ -d "$THUNDERBIRD_DIR" ] && [ ! -L "$THUNDERBIRD_DIR" ] && [ -z "$(ls -A "$DATA_DIR")" ]; then
              mv "$THUNDERBIRD_DIR"/* "$DATA_DIR"/
            fi

            # Delete the thunderbird default path and replace it with symlink
            rm -rf "$THUNDERBIRD_DIR"
            ln -s "$DATA_DIR" "$THUNDERBIRD_DIR"
          '';
        }
        (lib.mkIf (builtins.any (acc: acc.type == "proton") mainUser.emailAccounts) {
          home.packages = [ pkgs.protonmail-bridge ];
        })
      ];
  };

}
