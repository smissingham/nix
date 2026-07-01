{ lib, ... }:
{
  modules.nixos.gaming =
    { config, pkgs, ... }:
    let
      cfg = config.steam;
    in
    {
      options.steam.enable = lib.mkEnableOption "Steam gaming setup";

      config = lib.mkIf cfg.enable {

        programs = {
          gamemode.enable = true;
          steam = {
            enable = true;
            remotePlay.openFirewall = true;
            extraCompatPackages = [ pkgs.proton-ge-bin ];
          };
        };

        hardware.xone.enable = true;
        hardware.graphics.enable = true;
        hardware.graphics.enable32Bit = true;

      };
    };
}
