{ lib, ... }:
{
  modules.shared.spacedrive =
    {
      config,
      pkgsstable,
      ...
    }:
    let
      cfg = config.spacedrive;
    in
    {
      options.spacedrive = {
        enable = lib.mkEnableOption "Spacedrive with host-specific Wayland fixes";
      };

      config = lib.mkIf cfg.enable {
        environment.systemPackages = [ pkgsstable.spacedrive ];
      };
    };
}
