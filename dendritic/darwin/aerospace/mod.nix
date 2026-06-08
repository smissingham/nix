{ config, lib, ... }:
let
  name = "sm-darwin-aerospace";
  paths = config.flake.paths;
  configEtcPath = lib.removePrefix "/etc/" paths.config;
  bordersConfig = [
    "style=round"
    "hidpi=on"
    "active_color=0xff00FFDE"
    "width=5.0"
  ];
in
{
  perSystem =
    { pkgs, ... }:
    let
      aerospaceConfig = pkgs.writeTextDir "etc/${configEtcPath}/aerospace/aerospace.toml" (
        builtins.readFile ./aerospace.toml
      );

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
      packages = pkgs.lib.mkIf pkgs.stdenv.isDarwin {
        ${name} = pkgs.symlinkJoin {
          inherit name;
          paths = [
            pkgs.aerospace
            pkgs.jankyborders
            aerospaceConfig
            reloadAerospace
          ];
        };
      };
    };

  flake.darwinModules.aerospace =
    {
      config,
      mainUser,
      pkgs,
      ...
    }:
    let
      cfg = config.dendritic.darwin.aerospace;
      aerospacePackage = pkgs.${name};
    in
    {
      options.dendritic.darwin.aerospace.enable = lib.mkEnableOption "Dendritic AeroSpace setup";

      config = lib.mkIf cfg.enable {
        environment.systemPackages = [ aerospacePackage ];

        environment.etc."${configEtcPath}/aerospace/aerospace.toml".source =
          "${aerospacePackage}/etc/${configEtcPath}/aerospace/aerospace.toml";

        home-manager.users.${mainUser.username}.xdg.configFile."aerospace/aerospace.toml".source =
          "${aerospacePackage}/etc/${configEtcPath}/aerospace/aerospace.toml";

        launchd.user.agents = {
          aerospace = {
            serviceConfig = {
              ProgramArguments = [
                "${aerospacePackage}/Applications/AeroSpace.app/Contents/MacOS/AeroSpace"
              ];
              RunAtLoad = true;
              KeepAlive = true;
              StandardOutPath = "/tmp/aerospace.log";
              StandardErrorPath = "/tmp/aerospace.log";
            };
          };

          borders = {
            serviceConfig = {
              ProgramArguments = [ "${aerospacePackage}/bin/borders" ] ++ bordersConfig;
              RunAtLoad = true;
              StandardOutPath = "/tmp/borders.log";
              StandardErrorPath = "/tmp/borders.log";
            };
          };
        };
      };
    };
}
