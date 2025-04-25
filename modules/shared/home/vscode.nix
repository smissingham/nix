{
  config,
  lib,
  pkgs,
  mainUser,
  rootPath,
  pkgsUnstable,
  ...
}:

let
  moduleSet = "myHomeModules";
  moduleCategory = "devtools";
  moduleName = "vscode";

  cfg = config.${moduleSet}.${moduleCategory}.${moduleName};
in
{
  options.${moduleSet}.${moduleCategory}.${moduleName} = with lib; {
    enable = mkEnableOption moduleName;
    useCodium = mkOption {
      type = types.bool;
      default = true;
    };
    mutableExtensionsDir = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {

    #----- Applications in User Space -----#
    home-manager.users.${mainUser.username} = {

      home.file.".continue" = {
        source = ./dots/.continue;
        recursive = true;
      };

      programs.vscode = {
        enable = true;
        package = if cfg.useCodium then pkgsUnstable.vscodium else pkgsUnstable.vscode;
        mutableExtensionsDir = cfg.mutableExtensionsDir;

        userSettings = {

          "workbench.colorTheme" = lib.mkForce "Catppuccin Macchiato";
          "workbench.iconTheme" = "vscode-icons";
          "editor.formatOnSave" = true;
          "terminal.integrated.fontFamily" = "MesloLGS Nerd Font";
          "explorer.compactFolders" = false;
          "explorer.confirmDragAndDrop" = false;
          "explorer.confirmDelete" = false;

          # ---- Extension Settings ---- #
          "nix" = {
            "serverPath" = "nixd";
            "formatterPath" = "nixfmt";
          };

          "continue" = {
            "telemetryEnabled" = false;
          };
          "vsicons.dontShowNewVersionMessage" = true;
          "gitlens.telemetry.enabled" = false;
        };

        extensions = with pkgs.vscode-extensions; [
          # UI
          catppuccin.catppuccin-vsc
          vscode-icons-team.vscode-icons

          # Basic Language Support
          redhat.vscode-yaml

          # First Class Language Support
          ms-python.python
          ms-python.vscode-pylance

          # Nix
          bbenoist.nix
          jnoortheen.nix-ide

          # Remote Access
          #ms-vscode-remote.remote-ssh

          # Data Science Related
          ms-toolsai.datawrangler
          ms-toolsai.jupyter
          ms-toolsai.jupyter-renderers

          # Code Formatting
          esbenp.prettier-vscode

          # Version Control
          eamodio.gitlens

          # AI Assist
          continue.continue
        ];
      };
    };
  };
}
