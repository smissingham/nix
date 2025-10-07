{
  config,
  lib,
  mainUser,
  ...
}:
let
  moduleSet = "mySharedModules";
  moduleCategory = "workflow";
  moduleName = "sesh";
  moduleDots = "${config.environment.variables.NIX_CONFIG_HOME}/dots/modules/${moduleCategory}/${moduleName}";

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
    home-manager.users.${mainUser.username} =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        # unused currently, leaving room for pre-stow build steps
        buildScriptName = "build-${fullModuleName}";
        buildScriptContent = pkgs.writeShellScriptBin "${buildScriptName}" '''';
      in
      {
        imports = [
        ];
        home = {
          packages = with pkgs; [
            yazi
            tmux
            sesh
            gum
          ];
          shellAliases = {
            ts = "sesh connect \"$(sesh list -i | gum filter --limit 1 --placeholder 'Pick a sesh' --prompt='⚡')\"";
          };
          activation = {
            ${fullModuleName} = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
              ${pkgs.stow}/bin/stow -t "${config.xdg.configHome}" -d "${moduleDots}" -R .
              echo "Stowed dots for module ${fullModuleName}"
              ${buildScriptContent}/bin/${buildScriptName}
            '';
          };
        };
      };
  };
}
