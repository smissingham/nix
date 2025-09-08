{ pkgs, lib, ... }:

let
  inherit (pkgs.vscode-utils) buildVscodeMarketplaceExtension;
  ctrlKey = if pkgs.stdenv.isDarwin then "cmd" else "ctrl";

  extensions = with pkgs.vscode-extensions; [
    # ----- Theme & UI -----
    zhuangtongfa.material-theme
    vscode-icons-team.vscode-icons

    # ----- Language Support -----
    ms-python.python
    ms-pyright.pyright
    charliermarsh.ruff
    jnoortheen.nix-ide

    # Web & Config
    esbenp.prettier-vscode
    redhat.vscode-yaml
    tamasfe.even-better-toml

    # ----- Data Science -----
    ms-toolsai.jupyter
    ms-toolsai.jupyter-renderers
    (buildVscodeMarketplaceExtension {
      mktplcRef = {
        name = "vscode-jupytext";
        publisher = "congyiwu";
        version = "0.1.2";
        sha256 = "sha256-V9V4O1fdhY/ReKskixn113O0G1Mu1x9Z9SdChw9uVqU=";
      };
      meta = {
        homepage = "https://github.com/congyiwu/vscode-jupytext/blob/main/LICENSE.md";
        license = lib.licenses.bsd3;
      };
    })

    # ----- Editor Tools -----
    saoudrizwan.claude-dev # Cline
    eamodio.gitlens
    mkhl.direnv
    (buildVscodeMarketplaceExtension {
      mktplcRef = {
        name = "periscope";
        publisher = "joshmu";
        version = "1.15.1";
        sha256 = "sha256-Ssa3qoookSa/JnmZl1AmlT48exAgd6pbwdzzsmTcEqs=";
      };
      meta = {
        homepage = "https://github.com/joshmu/periscope";
        license = lib.licenses.mit;
      };
    })
  ];

  userSettings = {
    "workbench.colorTheme" = "One Dark Pro";
    "workbench.iconTheme" = "vscode-icons";
    "editor.formatOnSave" = true;
    "terminal.integrated.fontFamily" = "MesloLGS Nerd Font";
    "terminal.integrated.defaultLocation" = "editor";
    "explorer.compactFolders" = false;
    "explorer.confirmDragAndDrop" = false;
    "explorer.confirmDelete" = false;

    # Extension Settings
    "nix" = {
      "serverPath" = "nixd";
      "formatterPath" = "nixfmt";
    };

    "notebook.defaultFormatter" = "ms-toolsai.jupyter";
    "[python]" = {
      "editor.defaultFormatter" = "charliermarsh.ruff";
    };
    "[jupyter]" = {
      "editor.defaultFormatter" = "charliermarsh.ruff";
    };
    "jupyter.askForKernelRestart" = false;

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

  settingsJson = pkgs.writeText "settings.json" (builtins.toJSON userSettings);
  keybindingsJson = pkgs.writeText "keybindings.json" (builtins.toJSON keybindings);

in
let
  vscodiumWithExtensions = pkgs.vscode-with-extensions.override {
    vscode = pkgs.vscodium;
    vscodeExtensions = extensions;
  };
in
pkgs.runCommand "vscodium-configured"
  {
    buildInputs = [ pkgs.makeWrapper ];
  }
  ''
    mkdir -p $out/bin $out/share/vscodium-configured

    # Copy the VSCodium with extensions
    cp -r ${vscodiumWithExtensions}/* $out/

    # Add our configuration files
    cp ${settingsJson} $out/share/vscodium-configured/settings.json
    cp ${keybindingsJson} $out/share/vscodium-configured/keybindings.json
  ''
