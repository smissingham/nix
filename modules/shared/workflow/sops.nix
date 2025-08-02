{
  config,
  lib,
  pkgs,
  mainUser,
  inputs,
  ...
}:
let
  moduleSet = "mySharedModules";
  moduleCategory = "workflow";
  moduleName = "sops";

  optionPath = [
    moduleSet
    moduleCategory
    moduleName
  ];
  enablePath = optionPath ++ [ "enable" ];
  secretsFilePath = "${config.environment.variables.NIX_CONFIG_HOME}/private/secrets.yaml";
in
{
  options = lib.setAttrByPath optionPath {
    enable = lib.mkEnableOption moduleName;
  };

  config = lib.mkIf (lib.getAttrFromPath enablePath config) {
    #environment.variables.SOPS_SECRETS = secretsFilePath;

    home-manager.users.${mainUser.username} =
      {
        config,
        ...
      }:
      let
        keyDir = "${config.xdg.configHome}/sops/age";
        keyFile = "${keyDir}/keys.txt";
      in
      {
        imports = [
          inputs.sops-nix.homeManagerModules.sops
        ];

        sops = {
          defaultSopsFile = secretsFilePath;
          validateSopsFiles = false;

          age = {
            keyFile = keyFile;
          };

          secrets = {
            LITELLM_API_KEY = { };
          };
        };

        home = {
          packages = with pkgs; [
            age
            sops
          ];
          activation = {
            createKeyIfNotExists = ''
              if [ ! -f ${keyFile} ]; then
                mkdir -p ${keyDir}
                ${pkgs.age}/bin/age-keygen -o ${keyFile}
              fi
            '';
          };
        };
      };
  };
}
