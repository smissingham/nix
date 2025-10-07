{
  lib,
  mainUser,
  ...
}:

let
  moduleSet = "mySharedModules";
  moduleCategory = "browsers";

  searxngUrl = "https://searxng.coeus.missingham.net";

  searchEngineList = [
    {
      key = "nixospackages";
      name = "NixOS Packages";
      url = "https://search.nixos.org/packages?type=packages&query={searchTerms}";
      alias = "@np";
    }
    {
      key = "nixoswiki";
      name = "NixOS Wiki";
      url = "https://nixos.wiki/index.php?search={searchTerms}";
      alias = "@nw";
    }
    {
      key = "searxng";
      name = "SearXNG";
      url = "${searxngUrl}?q={searchTerms}";
      alias = "@sx";
    }
    {
      key = "github";
      name = "GitHub";
      url = "https://github.com/search?q={searchTerms}&type=code";
      alias = "@gh";
    }
    {
      key = "youtube";
      name = "YouTube";
      url = "https://youtube.com/results?search_query={searchTerms}";
      alias = "@yt";
    }
    {
      key = "mynixos";
      name = "MyNixOS";
      url = "https://mynixos.com/search?q={searchTerms}";
      alias = "@nx";
    }
  ];
in
{
  options.${moduleSet}.${moduleCategory} = with lib; {
    firefoxConfig = mkOption {
      type = types.attrs;
      internal = true;
    };

    chromiumConfig = mkOption {
      type = types.attrs;
      internal = true;
    };
  };

  config = {
    ${moduleSet}.${moduleCategory} = {
      firefoxConfig = {
        profiles.default = {
          id = 0;
          name = mainUser.username;

          settings = {
            "browser.startup.homepage" = searxngUrl;

            "browser.search.defaultenginename" = "SearXNG";
            "browser.search.order.1" = "SearXNG";

            "browser.search.region" = "US";
            "distribution.searchplugins.defaultLocale" = "en-US";
            "general.useragent.locale" = "en-US";
            "browser.bookmarks.showMobileBookmarks" = true;
            "browser.newtabpage.pinned" = [
              {
                title = "SearXNG";
                url = searxngUrl;
              }
            ];
          };

          search = {
            force = true;
            default = "searxng";
            order = [
              "searxng"
              "ddg"
              "google"
            ];
            engines = {
              "bing".metaData.hidden = true;
              "ddg".metaData.alias = "@ddg";
              "google".metaData.alias = "@g";
            }
            // (builtins.listToAttrs (
              map (engine: {
                name = engine.key;
                value = {
                  urls = [ { template = engine.url; } ];
                  updateInterval = 24 * 60 * 60 * 1000;
                  definedAliases = [ engine.alias ];
                };
              }) searchEngineList
            ));
          };
        };

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

      chromiumConfig = {
        commandLineArgs = [
          "--enable-features=WebUIDarkMode"
          "--force-dark-mode"
          "--disable-features=MediaRouter"
          "--disable-background-networking"
          "--disable-sync"
          "--disable-crash-reporter"
          "--disable-breakpad"
          "--metrics-recording-only"
          "--disable-component-update"
        ];

        searchEngines = map (engine: {
          name = engine.name;
          keyword = engine.alias;
          search_url = engine.url;
          is_default = engine.key == "searxng";
        }) searchEngineList;
      };
    };
  };
}
