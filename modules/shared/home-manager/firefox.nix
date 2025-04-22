{
  config,
  lib,
  pkgs,
  mainUser,
  ...
}:

let
  moduleSet = "myHomeModules";
  moduleCategory = "browsers";
  moduleName = "firefox";

  cfg = config.${moduleSet}.${moduleCategory}.${moduleName};
in
{
  options.${moduleSet}.${moduleCategory}.${moduleName} = with lib; {
    enable = mkEnableOption moduleName;
  };

  config = lib.mkIf cfg.enable {

    #----- Applications in User Space -----#
    home-manager.users.${mainUser.username} = {

      programs.firefox = {
        enable = true;
        profiles.default = {
          id = 0;
          name = mainUser.username;

          # list options here: https://searchfox.org/mozilla-release/source/browser/app/profile/firefox.js
          settings = {
            "browser.startup.homepage" = "https://mynixos.com/";
            "browser.search.region" = "US";
            "distribution.searchplugins.defaultLocale" = "en-US";
            "general.useragent.locale" = "en-US";
            "browser.bookmarks.showMobileBookmarks" = true;
            "browser.newtabpage.pinned" = [
              {
                title = "MyNixOS";
                url = "https://mynixos.com/";
              }
            ];
          };

        };

        # policy options here: https://mozilla.github.io/policy-templates/
        policies = {
          DisableTelemetry = true;
          DontCheckDefaultBrowser = true;
          DisablePocket = true;
          DisableFirefoxStudies = true;
          DisableFeedbackCommands = true;
          DisplayBookmarksToolbar = true;
          EnableTrackingProtection = true;
          OfferToSaveLogins = false;
          PasswordManagerEnabled = false;
        };

      };
    };
  };
}
