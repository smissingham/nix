{ lib, ... }:
{
  modules.darwin.skhd =
    {
      config,
      pkgs,
      ...
    }:
    let
      apps = config.user.apps;
      cfg = config.skhd;
      skhdConfig = pkgs.writeText "skhdrc" (builtins.readFile ./skhdrc);
      userConfigPath = "${config.user.paths.config}/skhd/skhdrc";
      reloadSkhd = pkgs.writeShellScriptBin "reload-skhd" ''
        set -euo pipefail
        /bin/launchctl kickstart -k gui/$(/usr/bin/id -u)/org.nixos.skhd || true
      '';
    in
    {
      options.skhd.enable = lib.mkEnableOption "skhd setup";

      config = lib.mkIf cfg.enable {
        environment.systemPackages = [
          pkgs.skhd
          reloadSkhd
        ];

        system.activationScripts.extraActivation.text = lib.mkAfter ''
          /bin/mkdir -p ${config.user.paths.config}/skhd
          /bin/ln -sfn ${skhdConfig} ${userConfigPath}
        '';

        launchd.user.agents.skhd = {
          serviceConfig = {
            EnvironmentVariables = {
              BROWSER = apps.browser;
              PATH = "${pkgs.skhd}/bin:/run/current-system/sw/bin:/bin:/usr/bin:/sbin:/usr/sbin";
              TERMINAL = apps.terminal;
            };
            ProgramArguments = [
              "${pkgs.skhd}/bin/skhd"
              "-c"
              userConfigPath
            ];
            RunAtLoad = true;
            StandardOutPath = "/tmp/skhd.log";
            StandardErrorPath = "/tmp/skhd.log";
          };
        };
      };
    };
}
