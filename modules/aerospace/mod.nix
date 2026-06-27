{ lib, ... }:
let
  bordersConfig = [
    "style=round"
    "hidpi=on"
    "active_color=0xff00FFDE"
    "width=5.0"
  ];
in
{
  modules.darwin.aerospace =
    {
      config,
      pkgs,
      ...
    }:
    let
      cfg = config.aerospace;
      aerospaceConfig = pkgs.writeText "aerospace.toml" (builtins.readFile ./aerospace.toml);
      userConfigPath = "${config.user.paths.config}/aerospace/aerospace.toml";
      reloadAerospace = pkgs.writeShellScriptBin "reload-aerospace" ''
        set -euo pipefail

        if /usr/bin/pgrep -x AeroSpace > /dev/null; then
          ${pkgs.aerospace}/bin/aerospace reload-config
        fi

        /bin/launchctl kickstart -k gui/$(/usr/bin/id -u)/org.nixos.aerospace || true
        /bin/launchctl kickstart -k gui/$(/usr/bin/id -u)/org.nixos.borders || true
      '';
    in
    {
      options.aerospace.enable = lib.mkEnableOption "AeroSpace setup";

      config = lib.mkIf cfg.enable {
        environment.systemPackages = [
          pkgs.aerospace
          pkgs.jankyborders
          reloadAerospace
        ];

        system.activationScripts.extraActivation.text = lib.mkAfter ''
          /bin/mkdir -p ${config.user.paths.config}/aerospace
          /bin/ln -sfn ${aerospaceConfig} ${userConfigPath}
        '';

        launchd.user.agents = {
          aerospace = {
            serviceConfig = {
              ProgramArguments = [
                "${pkgs.aerospace}/Applications/AeroSpace.app/Contents/MacOS/AeroSpace"
              ];
              RunAtLoad = true;
              KeepAlive = true;
              StandardOutPath = "/tmp/aerospace.log";
              StandardErrorPath = "/tmp/aerospace.log";
            };
          };

          borders = {
            serviceConfig = {
              ProgramArguments = [ "${pkgs.jankyborders}/bin/borders" ] ++ bordersConfig;
              RunAtLoad = true;
              StandardOutPath = "/tmp/borders.log";
              StandardErrorPath = "/tmp/borders.log";
            };
          };
        };
      };
    };
}
