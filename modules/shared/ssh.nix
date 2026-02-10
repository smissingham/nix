{
  config,
  lib,
  mainUser,
  ...
}:

let
  cfg = config.mySharedModules.ssh;

  # Find all SSH public key secrets in sops (pattern: SSH_PUBKEY_*)
  sshPubSecrets = lib.filterAttrs (name: _value: lib.hasPrefix "SSH_PUBKEY_" name) (
    mainUser.sops.secrets.other // mainUser.sops.secrets.autoExport
  );
  secretNames = builtins.attrNames sshPubSecrets;
in
{
  options.mySharedModules.ssh = with lib; {
    enable = mkEnableOption "SSH server and authorized keys management via sops";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${mainUser.username} =
      { config, lib, ... }:
      let
        # Build a script that concatenates all the secret files with newlines
        authorizedKeysScript = lib.concatMapStringsSep "\n" (secretName: ''
          cat ${config.sops.secrets.${secretName}.path}
          echo ""
        '') secretNames;
      in
      {
        # Declare all the sops secrets we need
        sops.secrets = lib.listToAttrs (
          map (secretName: {
            name = secretName;
            value = { };
          }) secretNames
        );

        # Use activation to write the authorized_keys file after sops secrets are available
        home.activation.sshAuthorizedKeys = lib.hm.dag.entryAfter [ "setupSops" ] ''
          mkdir -p $HOME/.ssh
          (
            ${authorizedKeysScript}
          ) > $HOME/.ssh/authorized_keys
          chmod 600 $HOME/.ssh/authorized_keys
        '';
      };
  };
}
