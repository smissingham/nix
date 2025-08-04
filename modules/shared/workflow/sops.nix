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
in
{
  options = lib.setAttrByPath optionPath {
    enable = lib.mkEnableOption moduleName;
  };

  config = lib.mkIf (lib.getAttrFromPath enablePath config) {
    home-manager.users.${mainUser.username} =
      let
        sopsPath = mainUser.sops.getPath { };
        secretsFile = "${sopsPath}/${mainUser.sops.secretsFileName}";
        ageKeyFile = "${sopsPath}/${mainUser.sops.ageKeyFileName}";
      in
      {
        imports = [
          inputs.sops-nix.homeManagerModules.sops
        ];

        sops = {
          defaultSopsFile = /. + secretsFile;
          validateSopsFiles = false;

          age = {
            keyFile = ageKeyFile;
          };

          secrets = mainUser.sops.secrets.autoExport // mainUser.sops.secrets.other;
        };

        home = {
          packages = with pkgs; [
            age
            sops
          ];
          sessionVariables = {
            SOPS_AGE_KEY_FILE = "${ageKeyFile}";
          };
          activation = {
            createKeyIfNotExists = ''
              if [ ! -d ${sopsPath} ]; then
                mkdir -p ${sopsPath}
              fi

              if [ ! -f ${ageKeyFile} ]; then
                ${pkgs.age}/bin/age-keygen -o ${ageKeyFile}
              fi
            '';
          };
        };
      };
  };
}
