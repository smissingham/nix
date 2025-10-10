# ----- DEFAULTS TO APPLY ONLY ON DARWIN SYSTEMS -----#
{ mainUser, ... }:
{
  system = {
    primaryUser = mainUser.username;

    # Auto install Rosetta if it's not already installed and we're on Apple Silicon
    activationScripts.extraActivation.text = ''
      if [[ $(uname -m) == "arm64" ]] && ! pkgutil --pkgs | grep -q "com.apple.pkg.RosettaUpdateAuto"; then
        softwareupdate --install-rosetta --agree-to-license
      fi
    '';
  };

  homebrew = {
    enable = true;
    taps = [
      "homebrew/core"
      "homebrew/cask"
      "homebrew/bundle"
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
