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
            ssh-to-age
            age-plugin-yubikey
            yubico-piv-tool
            yubikey-manager
          ];
          sessionVariables = {
            SOPS_AGE_KEY_FILE = "${ageKeyFile}";
          }
          // builtins.mapAttrs (_name: value: "$(cat ${value.path})") (
            lib.filterAttrs (name: _value: builtins.elem name exportKeys) (
              sysConfig.home-manager.users.${mainUser.username}.sops.secrets or { }
            )
          );
          activation = {
            createKeyIfNotExists = ''
              if [ ! -d ${sopsPath} ]; then
                mkdir -p ${sopsPath}
              fi

              # Make an age ID at given path if none there, prefer to use SSH key if present
              if [ ! -f ${ageKeyFile} ]; then
                if [ -f ~/.ssh/id_ed25519 ]; then
                  ${pkgs.ssh-to-age}/bin/ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ${ageKeyFile}
                else
                  ${pkgs.age}/bin/age-keygen -o ${ageKeyFile}
                fi
              fi
            '';
          };
        };
      };
    }
  );
}
