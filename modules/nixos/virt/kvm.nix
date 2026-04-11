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

  defaultNetworkXml = pkgs.writeText "libvirt-default-network.xml" ''
    <network>
      <name>default</name>
      <forward mode="nat"/>
      <bridge name="virbr0" stp="on" delay="0"/>
      <ip address="192.168.122.1" netmask="255.255.255.0">
        <dhcp>
          <range start="192.168.122.2" end="192.168.122.254"/>
        </dhcp>
      </ip>
    </network>
  '';
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
    ensureDefaultNetwork = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = lib.mkDefault 1;
      "net.ipv6.conf.all.forwarding" = lib.mkDefault 1;
    };

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
          # verbatimConfig = ''
          #   <video>
          #     <model type='virtio' vram='16384' heads='1'/>
          #   </video>
          # '';
        };
      };
    };

    systemd.services.libvirt-default-network = lib.mkIf cfg.ensureDefaultNetwork {
      description = "Ensure libvirt default network is defined and active";
      wantedBy = [ "multi-user.target" ];
      wants = [ "libvirtd.service" ];
      after = [ "libvirtd.service" ];
      path = [ pkgs.libvirt ];
      serviceConfig = {
        Type = "oneshot";
      };
      script = ''
        if ! virsh -c qemu:///system net-info default >/dev/null 2>&1; then
          virsh -c qemu:///system net-define "${defaultNetworkXml}"
        fi

        virsh -c qemu:///system net-autostart default
        virsh -c qemu:///system net-start default >/dev/null 2>&1 || true
      '';
    };

    programs.virt-manager.enable = cfg.withGuiTools;

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

        (lib.mkIf cfg.withGuiTools [
          remmina
        ])
      ];

  };
}
