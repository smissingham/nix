{
  config,
  lib,
  mainUser,
  pkgs,
  ...
}:

let
  moduleSet = "mySharedModules";
  moduleCategory = "browsers";
  moduleName = "brave";

  cfg = config.${moduleSet}.${moduleCategory}.${moduleName};

  searchEngineList = config.${moduleSet}.${moduleCategory}.chromiumConfig.searchEngines or [ ];

  managedPolicies = pkgs.writeText "brave-policies.json" (
    builtins.toJSON {
      ManagedSearchEngines = searchEngineList;
    }
  );
in
{
  options.${moduleSet}.${moduleCategory}.${moduleName} = with lib; {
    enable = mkEnableOption moduleName;
  };

  config = lib.mkIf cfg.enable {
    # TODO: ManagedSearchEngines policy not working - search engines not appearing in Brave
    # May need different approach for macOS (MDM policies or different file location)

    home-manager.users.${mainUser.username} = {

      programs.brave = {
        enable = true;
      }
      // (builtins.removeAttrs config.${moduleSet}.${moduleCategory}.chromiumConfig [ "searchEngines" ]);

      home.file.".config/BraveSoftware/Brave-Browser/managed_preferences.json".source = managedPolicies;
    };
  };
}
