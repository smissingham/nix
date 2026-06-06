{
  config,
  lib,
  ...
}:
let
  name = "sm-darwin-skhd";
  defaults = config.flake.defaults;
  paths = config.flake.paths;
  configEtcPath = lib.removePrefix "/etc/" paths.config;
in
{
  perSystem =
    { pkgs, ... }:
    let
      skhdConfig = pkgs.writeTextDir "etc/${configEtcPath}/skhd/skhdrc" (builtins.readFile ./skhdrc);

      reloadSkhd = pkgs.writeShellScriptBin "reload-skhd" ''
        set -euo pipefail
        /bin/launchctl kickstart -k gui/$(/usr/bin/id -u)/org.nixos.skhd || true
      '';

    in
    {
      packages = pkgs.lib.mkIf pkgs.stdenv.isDarwin {
        ${name} = pkgs.symlinkJoin {
          inherit name;
          paths = [
            pkgs.skhd
            skhdConfig
            reloadSkhd
          ];
        };
      };
    };

  flake.darwinModules.skhd =
    {
      config,
      pkgs,
      ...
    }:
    let
      cfg = config.dendritic.darwin.skhd;
      skhdPackage = pkgs.${name};
    in
    {
      options.dendritic.darwin.skhd.enable = lib.mkEnableOption "Dendritic skhd setup";

      config = lib.mkIf cfg.enable {
        environment.systemPackages = [ skhdPackage ];

        environment.etc."${configEtcPath}/skhd/skhdrc".source =
          "${skhdPackage}/etc/${configEtcPath}/skhd/skhdrc";

        system.activationScripts.extraActivation.text = lib.mkAfter ''
          /bin/mkdir -p ${paths.bin}
          /usr/bin/install -m 0755 ${pkgs.skhd}/bin/skhd ${paths.bin}/skhd
        '';

        launchd.user.agents.skhd = {
          serviceConfig = {
            EnvironmentVariables = {
              BROWSER = defaults.browser;
              PATH = lib.makeBinPath [
                pkgs.aerospace
                pkgs.skhd
              ] + ":/bin:/usr/bin:/sbin:/usr/sbin";
              TERMINAL = defaults.terminal;
              XDG_CACHE_HOME = paths.cache;
              XDG_CONFIG_HOME = paths.config;
              XDG_DATA_HOME = paths.data;
              XDG_STATE_HOME = paths.state;
            };
            ProgramArguments = [
              "${paths.bin}/skhd"
              "-c"
              "${paths.config}/skhd/skhdrc"
            ];
            RunAtLoad = true;
            StandardOutPath = "/tmp/skhd.log";
            StandardErrorPath = "/tmp/skhd.log";
          };
        };
      };
    };
}
