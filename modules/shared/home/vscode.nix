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

  # Import the extension builder only at the top level
  inherit (pkgs.vscode-utils) buildVscodeMarketplaceExtension;

  ctrlKey = if pkgs.stdenv.isDarwin then "cmd" else "ctrl";
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

      # home.file.".continue" = {
      #   source = ./dots/.continue;
      #   recursive = true;
      # };

      programs.vscode = {
        enable = true;
        package = (if cfg.useCodium then pkgsUnstable.vscodium else pkgsUnstable.vscode);
        mutableExtensionsDir = cfg.mutableExtensionsDir;

        userSettings = {
          # Your settings remain unchanged
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

        keybindings = [
          {
            key = "${ctrlKey}+shift+space";
            command = "periscope.search";
          }
        ];

        extensions =
          with pkgs.vscode-extensions;
          [
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
            pkgsUnstable.vscode-extensions.ms-vscode-remote.remote-ssh

            # Data Science Related
            ms-toolsai.datawrangler
            ms-toolsai.jupyter
            ms-toolsai.jupyter-renderers

            # Code Formatting
            esbenp.prettier-vscode

            # Version Control
            eamodio.gitlens
          ]

          # ----- Manually Specified Extensions ----- #
          ++ [

            # File Nav
            (buildVscodeMarketplaceExtension {
              mktplcRef = {
                name = "periscope";
                publisher = "joshmu";
                version = "1.10.0";
                sha256 = "sha256-Y94JwNoBhKIi/51YlPWoit6LW/AbWf190YARoKEQQew=";
              };
            })

            # AI Agent
            (buildVscodeMarketplaceExtension {
              mktplcRef = {
                name = "continue";
                publisher = "continue";
                version = "1.1.26";
                sha256 = "sha256-3WQ1dCOaU42a4loHTLlGsV3RPGJibqtC++yId1UMC3g=";
              };
              # nativeBuildInputs = [
              #   pkgs.autoPatchelfHook
              # ];
              buildInputs = [ pkgs.stdenv.cc.cc.lib ];
            })
          ];
      };
    };
  };
}
