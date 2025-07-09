# ----- DEFAULTS TO APPLY ONLY ON DARWIN SYSTEMS -----#
{ mainUser, pkgs, ... }:
{
  system = {
    primaryUser = mainUser.username;

    activationScripts.extraActivation.text = ''
      softwareupdate --install-rosetta --agree-to-license
    '';

  };

  homebrew = {
    enable = true;
    taps = [
      "homebrew/core"
      "homebrew/cask"
      "homebrew/bundle"
      "timrogers/tap"
    ];

    onActivation = {
      cleanup = "zap";
    };

    brews = [
      "libomp"
    ];
  };

  home-manager.users.${mainUser.username} = {

    targets.darwin.keybindings = {
      # Remap Home / End keys to be correct
      "\UF729" = "moveToBeginningOfLine:"; # Home
      "\UF72B" = "moveToEndOfLine:"; # End
    };
  };

}
