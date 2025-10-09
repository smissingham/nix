{
  config,
  lib,
  pkgs,
  mainUser,
  inputs,
  ...
}:
let
  sysConfig = config;
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

  config = lib.mkIf (lib.getAttrFromPath enablePath config) (
    let
      sopsPath = mainUser.sops.getPath { };
      secretsFile = "${sopsPath}/${mainUser.sops.secretsFileName}";
      ageKeyFile = "${sopsPath}/${mainUser.sops.ageKeyFileName}";
      exportKeys = builtins.attrNames mainUser.sops.secrets.autoExport;
    in
    {
      mySharedModules.workflow.shell.initExtras = builtins.concatStringsSep "\n" (
        builtins.attrValues (
          builtins.mapAttrs (name: value: "export ${name}=\"$(cat ${value.path})\"") (
            lib.filterAttrs (name: value: builtins.elem name exportKeys) (
              sysConfig.home-manager.users.${mainUser.username}.sops.secrets or { }
            )
          )
        )
      );

      home-manager.users.${mainUser.username} = {
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
            age-plugin-yubikey
            yubico-piv-tool
            yubikey-manager
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
    }
  );
}
