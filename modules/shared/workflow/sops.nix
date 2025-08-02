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
  moduleName = "sops";

  optionPath = [
    moduleSet
    moduleCategory
    moduleName
  ];
  fullModuleName = lib.concatStringsSep "." optionPath;
  enablePath = optionPath ++ [ "enable" ];
in
{
  options = lib.setAttrByPath optionPath {
    enable = lib.mkEnableOption moduleName;
  };

  config = lib.mkIf (lib.getAttrFromPath enablePath config) {
    home-manager.users.${mainUser.username} = {
      home = {
        packages = with pkgs; [
          age
          sops
        ];
        activation = {
          createKeyIfNotExists = ''
            if [ ! -f ~/.config/sops/age/keys.txt ]; then
              mkdir -p ~/.config/sops/age
              ${pkgs.age}/bin/age-keygen -o ~/.config/sops/age/keys.txt
            fi
          '';
        };
      };
    };
  };
}
