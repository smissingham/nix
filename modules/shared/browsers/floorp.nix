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
  moduleName = "floorp";

  cfg = config.${moduleSet}.${moduleCategory}.${moduleName};
in
{
  options.${moduleSet}.${moduleCategory}.${moduleName} = with lib; {
    enable = mkEnableOption moduleName;
  };

  config = lib.mkIf cfg.enable {

    #----- Applications in User Space -----#
    home-manager.users.${mainUser.username} = {

      programs.floorp = {
        enable = true;
        package = pkgs.floorp;
        #package = if pkgs.stdenv.isDarwin then null else pkgs.firefox;
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
              "searxng"
              "ddg"
              "google"
            ];
            engines = {
              "nixospackages" = {
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
              "nixoswiki" = {
                urls = [ { template = "https://nixos.wiki/index.php?search={searchTerms}"; } ];
                icon = "https://twenty-icons.com/nixos.org";
                updateInterval = 24 * 60 * 60 * 1000; # every day
                definedAliases = [ "@nw" ];
              };
              "searxng" = {
                urls = [ { template = "https://searxng.coeus.missingham.net?q={searchTerms}"; } ];
                icon = "https://twenty-icons.com/searxng.org";
                updateInterval = 24 * 60 * 60 * 1000; # every day
                definedAliases = [ "@sx" ];
              };
              "github" = {
                urls = [ { template = "https://github.com/search?q={searchTerms}&type=code"; } ];
                icon = "https://twenty-icons.com/github.com";
                updateInterval = 24 * 60 * 60 * 1000; # every day
                definedAliases = [ "@gh" ];
              };
              "youtube" = {
                urls = [ { template = "https://youtube.com/results?search_query={searchTerms}"; } ];
                icon = "https://twenty-icons.com/YouTube.com";
                updateInterval = 24 * 60 * 60 * 1000; # every day
                definedAliases = [ "@yt" ];
              };
              "bing".metaData.hidden = true;
              "ddg".metaData.alias = "@ddg";
              "google".metaData.alias = "@g"; # builtin engines only support specifying one additional alias
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
