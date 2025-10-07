{
  config,
  lib,
  pkgs,
  mainUser,
  ...
}:
let
  moduleSet = "mySharedModules";
  moduleCategory = "devtools";
  moduleName = "smissingham-vscode";

  optionPath = [
    moduleSet
    moduleCategory
    moduleName
  ];
  enablePath = optionPath ++ [ "enable" ];

  binaryName = "codium";

in
{
  options = lib.setAttrByPath optionPath {
    enable = lib.mkEnableOption moduleName;
    withAliases = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Includes Sean's favourite shell alias helpers";
    };
  };

  config = lib.mkIf (lib.getAttrFromPath enablePath config) {
    home-manager.users.${mainUser.username} =
      let
        systemConfig = config;
      in
      {
        home = lib.mkMerge [

          # ----- Always Install -----#
          {
            packages = pkgs.myapps.smissingham-vscode.systemPackages;
          }

          # ----- Optional: Favourite Aliases -----#
          (lib.mkIf (lib.getAttrFromPath (optionPath ++ [ "withAliases" ]) systemConfig) {
            shellAliases = {
              vs = "${binaryName}";
              code = "${binaryName}";
            };
          })
        ];
      };
  };
}
