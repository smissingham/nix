{ lib, ... }:
{
  modules.nixos.kvm =
    {
      config,
      pkgs,
      user,
      ...
    }:
    let
      cfg = config.kvm;

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
      options.kvm = {
        enable = lib.mkEnableOption "KVM virtualization setup";

        withCliTools = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };

        withGuiTools = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };

        restartGuestsOnBoot = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };

        ensureDefaultNetwork = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
      };

      config = lib.mkIf cfg.enable {
        boot.kernel.sysctl = {
          "net.ipv4.ip_forward" = lib.mkDefault 1;
          "net.ipv6.conf.all.forwarding" = lib.mkDefault 1;
        };

        users.users.${user.username}.extraGroups = [ "libvirtd" ];

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
              vhostUserPackages = [ pkgs.virtiofsd ];
            };
          };
        };

        systemd.services.libvirt-default-network = lib.mkIf cfg.ensureDefaultNetwork {
          description = "Ensure libvirt default network is defined and active";
          wantedBy = [ "multi-user.target" ];
          wants = [ "libvirtd.service" ];
          after = [ "libvirtd.service" ];
          path = [ pkgs.libvirt ];
          serviceConfig.Type = "oneshot";
          script = ''
            if ! virsh -c qemu:///system net-info default >/dev/null 2>&1; then
              virsh -c qemu:///system net-define "${defaultNetworkXml}"
            fi

            virsh -c qemu:///system net-autostart default
            virsh -c qemu:///system net-start default >/dev/null 2>&1 || true
          '';
        };

        programs.virt-manager.enable = cfg.withGuiTools;

        environment.systemPackages = [
          pkgs.virtiofsd
          pkgs.virtio-win
        ]
        ++ lib.optionals cfg.withGuiTools [ pkgs.remmina ];
      };
    };
}
