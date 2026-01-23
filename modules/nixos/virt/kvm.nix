{
  config,
  lib,
  pkgs,
  mainUser,
  ...
}:
let
  moduleSet = "myNixOSModules";
  moduleCategory = "virt";
  moduleName = "kvm";

  cfg = config.${moduleSet}.${moduleCategory}.${moduleName};
in
{
  options.${moduleSet}.${moduleCategory}.${moduleName} = with lib; {
    enable = mkEnableOption moduleName;
    withCliTools = mkOption {
      type = types.bool;
      default = false;
    };
    withGuiTools = mkOption {
      type = types.bool;
      default = false;
    };
    restartGuestsOnBoot = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${mainUser.username}.extraGroups = [ "libvirtd" ];

    virtualisation = {
      spiceUSBRedirection.enable = true;
      libvirtd = {
        enable = true;
        allowedBridges = [
          "nm-bridge"
          "virbr0"
        ];
        onBoot = if cfg.restartGuestsOnBoot then "start" else "ignore";
        qemu = {
          package = pkgs.qemu_kvm;
          runAsRoot = true;
          swtpm.enable = true;
          vhostUserPackages = [ pkgs.virtiofsd ]; # causing freezing/lagging issues?
          verbatimConfig = ''
            <video>
              <model type='virtio' vram='16384' heads='1'/>
            </video>
            <graphics type='spice' port='-1' autoport='yes' listen='0.0.0.0'>
              <listen type='address' address='0.0.0.0'/>
            </graphics>
          '';
        };
      };
    };

    environment.systemPackages =
      with pkgs;
      lib.mkMerge [
        # Always install packages
        ([
          virtiofsd
          virtio-win
        ])

        # # Optional CLI Tools -- NOT YET NEEDED, LIBVIRT package ships the cli tools
        (lib.mkIf cfg.withCliTools [
          #libguestfs
        ])

        # Optional GUI Tools
        (lib.mkIf cfg.withGuiTools [ virt-manager ])
      ];

  };
}
