flake@{ inputs, ... }:
{
  hosts.opi = {
    system = "aarch64-linux";
    module =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        imports = [
          inputs.nixos-cix-cd8180.nixosModules.orangepi6plus
          flake.config.profiles.smissingham
          flake.config.hosts.shared
          flake.config.modules.nixos.firewall
          flake.config.modules.nixos.ssh
        ];

        #---------- APPLICATIONS ----------#
        ssh.enable = true;

        #---------- HOST IDENTITY ----------#
        time.timeZone = "America/Chicago";

        users.users.${config.user.username} = {
          isNormalUser = true;
          extraGroups = [
            "wheel"
            "networkmanager"
          ];
        };

        networking = {
          hostName = "opi";
          useDHCP = lib.mkDefault true;
          firewall.enable = lib.mkDefault true;
          networkmanager.enable = lib.mkDefault true;
        };

        #---------- ORANGE PI 6 PLUS / CIX SKY1 ----------#
        boot.kernelParams = [
          "boot.shell_on_fail"
        ];

        environment.systemPackages = [
          pkgs.git
        ];

        fileSystems."/" = lib.mkDefault {
          device = "/dev/disk/by-label/NIXOS_SD";
          fsType = "ext4";
        };

        fileSystems."/boot" = lib.mkDefault {
          device = "/dev/disk/by-label/BOOT";
          fsType = "vfat";
        };
      };
  };
}
