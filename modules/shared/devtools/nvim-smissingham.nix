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
  moduleName = "nvim-smissingham";

  optionPath = [
    moduleSet
    moduleCategory
    moduleName
  ];
  fullModuleName = lib.concatStringsSep "." optionPath;
  enablePath = optionPath ++ [ "enable" ];

  binaryName = "nvim-smissingham";
  flakePath = "${config.environment.variables.NIX_CONFIG_HOME}/flakes/nvim-smissingham";
  flake = builtins.getFlake "path:${flakePath}";

in
{
  options = lib.setAttrByPath optionPath {
    enable = lib.mkEnableOption moduleName;
    withAliases = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Includes Sean's favourite shell alias helpers";
    };
    withEnvVars = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Includes Sean's favourite env var helpers";
    };
    liveConfig = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Removes the nix-store symlinked config and replaces with direct symlink for live updates";
    };
  };

  config = lib.mkIf (lib.getAttrFromPath enablePath config) {
    home-manager.users.${mainUser.username} =
      let
        systemConfig = config;
      in
      {
        config,
        ...
      }:
      let
        srcConfigDir = "${flakePath}/nvim";
        tgtConfigDir = "${config.xdg.configHome}/${binaryName}";

        tgtConfDelete = "rm -rf ${tgtConfigDir}";
        tgtConfLiveSymlink = "ln -s ${srcConfigDir} ${tgtConfigDir}";
      in
      {
        home = lib.mkMerge [

          # ----- Always Install -----#
          {
            packages = flake.packages.${pkgs.system}.systemPackages;
          }

          # ----- Optional: Favourite Aliases -----#
          (lib.mkIf (lib.getAttrFromPath (optionPath ++ [ "withAliases" ]) systemConfig) {
            shellAliases = {
              # ---- Launch Shortcuts -----#
              sv = "${binaryName}"; # --- Launch Main Binary
              svf = "nix develop ${flakePath}#default -c ${binaryName}"; # --- Launch Nix Flake In Place

              # ----- Config & State Resetting -----#
              svda = "svdPerms && svdConfig && svdShare && svdState && svdLink";
              svdLink = "echo \"Config Linked to Nix Store\"";
              svdPerms = "chmod -R 755 ${tgtConfigDir}";
              svdConfig = "rm -rf ${tgtConfigDir}";
              svdShare = "rm -rf ~/.local/share/${binaryName}";
              svdState = "rm -rf ~/.local/state/${binaryName}";
            };
          })

          # ----- Optional: Env Variables-----#
          (lib.mkIf (lib.getAttrFromPath (optionPath ++ [ "withEnvVars" ]) systemConfig) {
            sessionVariables = {
              EDITOR = "${binaryName}";
            };
          })

          # ----- Optional: Live Config Stow instead of Symlink to Nix Store -----#
          (lib.mkIf (lib.getAttrFromPath (optionPath ++ [ "liveConfig" ]) systemConfig) {
            activation = {
              ${fullModuleName} = ''
                ${tgtConfDelete}
                ${tgtConfLiveSymlink}
              '';
            };
            shellAliases = {
              svdLink = lib.mkForce "${tgtConfLiveSymlink} && echo \"Config Linked to Live Folder\"";
            };
          })
        ];
      };
  };
}
