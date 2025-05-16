{
  config,
  lib,
  pkgs,
  mainUser,
  pkgsUnstable,
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
        package = if pkgs.stdenv.isDarwin then null else pkgs.firefox;
        profiles.default = {
          id = 0;
          name = mainUser.username;

          # list options here: https://searchfox.org/mozilla-release/source/browser/app/profile/firefox.js
          settings = {
            "browser.startup.homepage" = "https://searxng.coeus.missingham.net";

            "browser.search.defaultenginename" = "SearXNG";
            "browser.search.order.1" = "SearXNG";

            "browser.search.region" = "US";
            "distribution.searchplugins.defaultLocale" = "en-US";
            "general.useragent.locale" = "en-US";
            "browser.bookmarks.showMobileBookmarks" = true;
            "browser.newtabpage.pinned" = [
              {
                title = "SearXNG";
                url = "https://searxng.coeus.missingham.net";
              }
            ];
          };

          search = {
            force = true;
            default = "SearXNG";
            order = [
              "SearXNG"
              "ddg"
              "Google"
            ];
            engines = {
              "Nix Packages" = {
                urls = [
                  {
                    template = "https://search.nixos.org/packages";
                    params = [
                      {
                        name = "type";
                        value = "packages";
                      }
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "@np" ];
              };
              "NixOS Wiki" = {
                urls = [ { template = "https://nixos.wiki/index.php?search={searchTerms}"; } ];
                iconUpdateURL = "https://twenty-icons.com/nixos.org";
                updateInterval = 24 * 60 * 60 * 1000; # every day
                definedAliases = [ "@nw" ];
              };
              "SearXNG" = {
                urls = [ { template = "https://searxng.coeus.missingham.net?q={searchTerms}"; } ];
                iconUpdateURL = "https://twenty-icons.com/searxng.org";
                updateInterval = 24 * 60 * 60 * 1000; # every day
                definedAliases = [ "@sx" ];
              };
              "GitHub" = {
                urls = [ { template = "https://github.com/search?q={searchTerms}&type=code"; } ];
                iconUpdateURL = "https://twenty-icons.com/github.com";
                updateInterval = 24 * 60 * 60 * 1000; # every day
                definedAliases = [ "@gh" ];
              };
              "YouTube" = {
                urls = [ { template = "https://youtube.com/results?search_query={searchTerms}"; } ];
                iconUpdateURL = "https://twenty-icons.com/YouTube.com";
                updateInterval = 24 * 60 * 60 * 1000; # every day
                definedAliases = [ "@yt" ];
              };
              "Bing".metaData.hidden = true;
              "DuckDuckGo".metaData.alias = "@ddg";
              "Google".metaData.alias = "@g"; # builtin engines only support specifying one additional alias
            };
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
