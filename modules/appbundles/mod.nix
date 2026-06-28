flake@{ inputs, ... }:
{
  modules.shared.appbundles =
    module@{
      lib,
      pkgs,
      ...
    }:
    let
      cfg = module.config.appbundles;
      inherit (lib) mkIf optionals;

      mypkgs = inputs.mypkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};

      packages = {
        comms = [
          # pkgs.signal-desktop
          pkgs.vesktop
        ];

        development = [
          pkgs.sm-devtools
        ];

        linuxDevelopment = [ pkgs.jetbrains.idea-oss ];

        productivity = [
          mypkgs.brave-origin
          pkgs.handy
          pkgs.inkscape
          pkgs.obsidian
        ];

        linuxProductivity = [
          pkgs.gimp
          pkgs.onlyoffice-desktopeditors
        ];

        entertainment = [ pkgs.spotify ];
      };
    in
    {
      imports = [
        flake.config.modules.shared.alacritty
        flake.config.modules.shared.spacedrive
      ];

      options.appbundles = {
        comms.enable = lib.mkEnableOption "communications app bundle";
        development.enable = lib.mkEnableOption "development app bundle";
        productivity.enable = lib.mkEnableOption "productivity app bundle";
        entertainment.enable = lib.mkEnableOption "entertainment app bundle";
      };

      config = lib.mkMerge [
        (mkIf cfg.development.enable {
          alacritty.enable = true;
        })
        (mkIf cfg.productivity.enable {
          spacedrive.enable = true;
        })
        {
          environment.systemPackages =
            optionals (cfg.development.enable && pkgs.stdenv.isLinux) packages.linuxDevelopment
            ++ optionals cfg.development.enable packages.development
            ++ optionals cfg.productivity.enable packages.productivity
            ++ optionals (cfg.productivity.enable && pkgs.stdenv.isLinux) packages.linuxProductivity
            ++ optionals cfg.entertainment.enable packages.entertainment
            ++ optionals cfg.comms.enable packages.comms;
        }
      ];
    };

  modules.darwin.appbundlesHomebrew =
    { config, lib, ... }:
    let
      cfg = config.appbundles;

      casks = {
        productivity = [
          "raycast"
          "microsoft-teams"
          "microsoft-excel"
          "microsoft-powerpoint"
          "microsoft-word"
          "gimp"
        ];

        entertainment = [
          "stremio"
          "vlc"
          "obs"
        ];
      };
    in
    {
      config.homebrew.casks =
        lib.optionals cfg.productivity.enable casks.productivity
        ++ lib.optionals cfg.entertainment.enable casks.entertainment;
    };
}
