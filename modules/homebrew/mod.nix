{ inputs, lib, ... }:
{
  modules.darwin.homebrew =
    { config, ... }:
    let
      cfg = config.homebrewSetup;
    in
    {
      imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ];

      options.homebrewSetup.enable = lib.mkEnableOption "Homebrew setup";

      config = lib.mkIf cfg.enable {
        nix-homebrew = {
          enable = true;
          enableRosetta = true;
          user = config.user.username;
          autoMigrate = true;
          mutableTaps = false;
          taps = {
            "homebrew/homebrew-core" = inputs.homebrew-core;
            "homebrew/homebrew-cask" = inputs.homebrew-cask;
            "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
          };
        };

        homebrew = {
          enable = true;
          taps = [
            "homebrew/core"
            "homebrew/cask"
            "homebrew/bundle"
          ];

          onActivation.cleanup = "zap";
        };

        system.activationScripts.extraActivation.text = lib.mkAfter ''
          if [[ $(uname -m) == "arm64" ]] && ! pkgutil --pkgs | grep -q "com.apple.pkg.RosettaUpdateAuto"; then
            softwareupdate --install-rosetta --agree-to-license
          fi
        '';
      };
    };
}
