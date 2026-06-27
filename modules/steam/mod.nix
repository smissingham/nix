{ lib, ... }:
{
  modules.nixos.steam =
    { config, pkgs, ... }:
    let
      cfg = config.steam;
    in
    {
      options.steam.enable = lib.mkEnableOption "Steam gaming setup";

      config = lib.mkIf cfg.enable {
        environment.systemPackages = [
          pkgs.protonup-ng
          pkgs.gamescope
        ];

        programs = {
          steam = {
            enable = true;
            remotePlay.openFirewall = true;
            extest.enable = true;
            extraCompatPackages = [ pkgs.proton-ge-bin ];
          };

          gamemode.enable = true;
        };

        hardware.xone.enable = true;
      };
    };
}
