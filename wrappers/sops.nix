{
  config,
  lib,
  pkgs,
  wlib,
  ...
}:
{
  imports = [ wlib.modules.default ];
  options = {
    age = {
      keyFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "/home/alice/.config/sops/age/keys.txt";
        description = ''
          Path to the age identity file used by SOPS.

          When set, this sets env var SOPS_AGE_KEY_FILE.
        '';
      };
    };

    configFile = lib.mkOption {
      type = wlib.types.file {
        path = lib.mkOptionDefault config.constructFiles.generatedConfig.path;
      };
      default = { };
      example.path = "/home/alice/.sops.yaml";
      description = ''
        Path or inline definition for the SOPS YAML config file.

        By default, this points to the generated config built from settings.
        If content is set, it is used as literal YAML and settings is ignored.
      '';
    };

    settings = lib.mkOption {
      type = wlib.types.structuredValueWith {
        nullable = false;
        typeName = "YAML";
      };
      default = { };
      example.creation_rules = [
        {
          path_regex = "secrets.yaml$";
          age = "age1...";
        }
      ];
      description = ''
        SOPS YAML configuration as a Nix value.

        This is serialized directly to .sops.yaml without schema validation.
        Use configFile.content instead when YAML-specific features like anchors are needed.

        See <https://getsops.io/docs/>.
      '';
    };
  };
  config = {
    binName = lib.mkDefault "sops";
    package = lib.mkDefault pkgs.sops;

    envDefault = {
      SOPS_CONFIG = config.configFile.path;
      SOPS_AGE_KEY_FILE = lib.mkIf (config.age.keyFile != null) config.age.keyFile;
    };

    constructFiles.generatedConfig = {
      content =
        if (config.configFile.content or "") != "" then
          config.configFile.content
        else
          builtins.toJSON config.settings;
      relPath = "${config.binName}-config.yaml";
      builder = lib.mkIf (
        (config.configFile.content or "") == ""
      ) ''${pkgs.remarshal}/bin/json2yaml "$1" "$2"'';
    };

    meta.description = ''
      Nix wrapper module for configuration of SOPS (Secrets OPerationS).

      See <https://getsops.io/docs/>.
    '';
    meta.maintainers = [ wlib.maintainers.smissingham ];
  };
}
