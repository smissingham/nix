{
  config,
  lib,
  pkgs,
  ...
}:
let
  moduleSet = "mySharedModules";
  moduleCategory = "devtools";
  moduleName = "nvim-smissingham";

  optionPath = [
    moduleSet
    moduleCategory
    moduleName
  ];
  enablePath = optionPath ++ [ "enable" ];

  flake = builtins.getFlake "path:${config.environment.variables.NIX_CONFIG_HOME}/flakes/nvim-smissingham";
  binaryName = "nvim-smissingham";
in
{
  options = lib.setAttrByPath optionPath {
    enable = lib.mkEnableOption moduleName;
    withAliases = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    withEnvVars = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf (lib.getAttrFromPath enablePath config) {
    environment = lib.mkMerge [

      # ----- Always Install -----#
      {
        systemPackages = flake.packages.${pkgs.system}.systemPackages;
      }

      # ----- Optional: Favourite Aliases -----#
      (lib.mkIf (lib.getAttrFromPath (optionPath ++ [ "withAliases" ]) config) {
        shellAliases = {
          sv = "${binaryName}";
          svda = "svdPerms && svdConfig && svdShare && svdState";
          svdPerms = "chmod -R 755 ~/.config/${binaryName}";
          svdConfig = "rm -rf ~/.config/${binaryName}";
          svdShare = "rm -rf ~/.local/share/${binaryName}";
          svdState = "rm -rf ~/.local/state/${binaryName}";
        };
      })

      # ----- Optional: Env Variables-----#
      (lib.mkIf (lib.getAttrFromPath (optionPath ++ [ "withEnvVars" ]) config) {
        variables = {
          EDITOR = "${binaryName}";
        };
      })
    ];
  };
}
