{ mainUser, ... }:
{
  config = {
    home-manager.users.${mainUser.username} =
      { config, ... }:
      let
        secretNames = [
          "HOSTING_ROOT"
          "HOSTING_ADMIN_EMAIL"
          "HOSTING_ADMIN_USERNAME"
          "HOSTING_ADMIN_PASSWORD"
          "HOSTING_CF_API_TOKEN"
          "HOSTING_JWT_SECRET"
          "HOSTING_COMMON_MASTER_KEY"
          "HOSTING_LIBRECHAT_CREDS_KEY"
          "HOSTING_LIBRECHAT_CREDS_IV"
          "HOSTING_LIBRECHAT_JWT_SECRET"
          "HOSTING_LIBRECHAT_JWT_REFRESH_SECRET"
          "HOSTING_OPENROUTER_API_KEY"
          # ----- Games ----- #
          "FACTORIO_USERNAME"
          "FACTORIO_TOKEN"
        ];
        secret = name: "$(cat ${config.sops.secrets.${name}.path})";
      in
      {
        sops.secrets = builtins.listToAttrs (
          map (name: {
            name = name;
            value = { };
          }) secretNames
        );

        home.sessionVariables = builtins.listToAttrs (
          map (name: {
            name = name;
            value = secret name;
          }) secretNames
        );
      };
  };
}
