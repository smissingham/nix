{
  config,
  lib,
  pkgs,
  wlib,
  ...
}:
let
  indent = lib.replaceStrings [ "\n" ] [ "\n  " ];

  orderedAttrsToList =
    attrs:
    let
      preferredOrder = [
        "enabled"
        "bezier"
        "animation"
      ];
      preferredNames = builtins.filter (name: builtins.hasAttr name attrs) preferredOrder;
      remainingNames = lib.subtractLists preferredNames (lib.attrNames attrs);
    in
    map (name: {
      inherit name;
      value = attrs.${name};
    }) (preferredNames ++ remainingNames);

  renderValue = value: if lib.isBool value then lib.boolToString value else toString value;

  renderSetting =
    name: value:
    if lib.isList value then
      lib.concatMapStringsSep "\n" (item: renderSetting name item) value
    else if lib.isAttrs value then
      ''
        ${name} {
          ${indent (
            lib.concatMapStringsSep "\n" ({ name, value }: renderSetting name value) (orderedAttrsToList value)
          )}
        }
      ''
    else
      "${name} = ${renderValue value}";
in
{
  imports = [ wlib.modules.default ];

  options = {
    launchShortcut = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Optional extra executable alias for launching Hyprland.
      '';
    };

    nixGL = {
      autoDetect = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Allow start-hyprland to auto-detect nixGL requirements.

          Disable this on NixOS to skip the Hyprland version probe used for nixGL detection.
        '';
      };
    };

    luaConfig = {
      configBefore = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = ''
          Lua content emitted before imported Lua files.
        '';
      };

      content = lib.mkOption {
        type = lib.types.nullOr lib.types.lines;
        default = null;
        description = ''
          Complete Hyprland Lua configuration.

          When set, this replaces generated legacy config output.
        '';
      };

      configAfter = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = ''
          Lua content emitted after imported Lua files.
        '';
      };

      imports = lib.mkOption {
        type = lib.types.listOf lib.types.path;
        default = [ ];
        description = ''
          Lua files to load before luaConfig.content.
        '';
      };
    };

    nvidia = {
      enable = lib.mkEnableOption "NVIDIA-specific Hyprland session compatibility settings";

      disableWebKitDmabufRenderer = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Disable WebKitGTK DMABUF renderer for NVIDIA Wayland sessions.
        '';
      };
    };

    disableConfigValidation = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Disable build-time validation of the generated Hyprland config.
      '';
    };

    settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      description = ''
        Hyprland configuration settings.

        Attribute names become Hyprland config directives or sections.
        List values emit repeated directives.
      '';
    };
  };

  config = {
    binName = lib.mkDefault "Hyprland";
    aliases = lib.mkDefault [ "hyprland" ];
    package = lib.mkDefault pkgs.hyprland;

    flags."--config" = config.constructFiles.generatedConfig.path;

    drv.installPhase = lib.mkIf (!config.disableConfigValidation) ''
      runHook preInstall
      export XDG_RUNTIME_DIR="$TMPDIR/hyprland-runtime"
      mkdir -p "$XDG_RUNTIME_DIR"
      ${lib.getExe config.package} --verify-config --config ${config.constructFiles.generatedConfig.path}
      runHook postInstall
    '';

    constructFiles = {
      generatedConfig = {
        content =
          if config.luaConfig.content != null then
            lib.concatStringsSep "\n" (
              [ config.luaConfig.configBefore ]
              ++ (map (file: ''dofile("${file}")'') config.luaConfig.imports)
              ++ [
                config.luaConfig.content
                config.luaConfig.configAfter
              ]
            )
          else
            lib.concatStringsSep "\n" (lib.mapAttrsToList renderSetting config.settings);
        relPath = if config.luaConfig.content != null then "hyprland.lua" else "hyprland.conf";
      };

      launchShortcut = lib.mkIf (config.launchShortcut != null) {
        relPath = "bin/${config.launchShortcut}";
        builder = ''cp "$1" "$2" && chmod +x "$2"'';
        content = ''
          #!${pkgs.bash}/bin/bash
          log_dir="''${XDG_RUNTIME_DIR:-/tmp}/hypr"
          mkdir -p "$log_dir"
          exec "$(dirname "$0")/start-hyprland" ${
            lib.optionalString (!config.nixGL.autoDetect) "--no-nixgl"
          } "$@" >> "$log_dir/start-hyprland.log" 2>&1
        '';
      };
    };

    settings.env = lib.mkIf (config.luaConfig.content == null) (
      lib.mkBefore (
        lib.optionals config.nvidia.enable [
          "GBM_BACKEND,nvidia-drm"
          "__GLX_VENDOR_LIBRARY_NAME,nvidia"
          "LIBVA_DRIVER_NAME,nvidia"
        ]
        ++ lib.optionals (config.nvidia.enable && config.nvidia.disableWebKitDmabufRenderer) [
          "WEBKIT_DISABLE_DMABUF_RENDERER,1"
        ]
      )
    );

    luaConfig.configBefore = lib.mkIf (config.luaConfig.content != null) (
      lib.mkBefore (
        lib.concatStringsSep "\n" (
          lib.optionals config.nvidia.enable [
            ''hl.env("GBM_BACKEND", "nvidia-drm")''
            ''hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")''
            ''hl.env("LIBVA_DRIVER_NAME", "nvidia")''
          ]
          ++ lib.optionals (config.nvidia.enable && config.nvidia.disableWebKitDmabufRenderer) [
            ''hl.env("WEBKIT_DISABLE_DMABUF_RENDERER", "1")''
          ]
        )
      )
    );

    meta.description = ''
      Nix wrapper module for Hyprland configuration.
    '';
    meta.maintainers = [ wlib.maintainers.smissingham ];
    meta.platforms = lib.platforms.linux;
  };
}
