flake@{ ... }:
let
  raidArrayUuid = "1a4472d8:968793fc:43c574a9:8a440ed9";
in
{
  hosts.coeus = {
    system = "x86_64-linux";
    module =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        imports = [
          flake.config.profiles.smissingham
          flake.config.hosts.shared
          flake.config.modules.shared.appbundles
          # flake.config.modules.shared.nixbuilders
          flake.config.modules.shared.sops
          flake.config.modules.nixos.hyprland
          flake.config.modules.nixos.noctalia
          flake.config.modules.nixos.podman
          flake.config.modules.nixos.ssh
          flake.config.modules.nixos.steam
          flake.config.modules.nixos.syncthing
          flake.config.modules.nixos.sunshine
          flake.config.modules.nixos.tailscale
        ];

        #---------- HOST-ONLY PACKAGES ----------#
        environment.systemPackages = [
          pkgs.nvitop
        ];

        #---------- BUNDLES ----------#
        appbundles = {
          comms.enable = true;
          development.enable = true;
          entertainment.enable = true;
          productivity.enable = true;
        };

        #---------- APPLICATIONS ----------#
        podman.enable = true;
        sops.enable = true;
        ssh.enable = true;
        steam.enable = true;
        sunshine.enable = true;
        syncthing.enable = true;
        tailscale.enable = true;

        #---------- FEATURES ----------#
        # nixbuilders = {
        #   enable = true;
        #   systems = [
        #     "x86_64-linux"
        #     "aarch64-linux"
        #   ];
        # };

        noctalia = {
          enable = true;
          gtk = {
            textScalingFactor = 1.25;
            xftDpi = 122880;
          };
        };
        hyprland = {
          enable = true;
          nvidia = {
            enable = true;
            disableWebKitDmabufRenderer = true;
          };
          outputs = {
            "HDMI-A-2" = {
              mode = "5120x2160@120.000";
              scale = 1.25;
            };
          };
        };

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
          hostName = "coeus";
          useDHCP = lib.mkDefault true;
          firewall.enable = lib.mkDefault true;
          networkmanager.enable = lib.mkDefault true;
          firewall.allowedTCPPorts = [
            3000
            9876
            9877
            9878
          ];
        };

        services.fail2ban = {
          enable = true;
          maxretry = 5;
          ignoreIP = [
            "plutus"
          ];
          bantime = "24h";
          bantime-increment = {
            enable = true;
            formula = "ban.Time * math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)";
            overalljails = true;
          };
        };

        #---------- HOST BEHAVIOUR ----------#
        services.keyd = {
          enable = true;
          keyboards.default = {
            ids = [ "*" ];
            settings.main.capslock = "esc";
          };
        };

        i18n = {
          defaultLocale = "en_US.UTF-8";
          extraLocaleSettings = {
            LC_ADDRESS = "en_US.UTF-8";
            LC_IDENTIFICATION = "en_US.UTF-8";
            LC_MEASUREMENT = "en_US.UTF-8";
            LC_MONETARY = "en_US.UTF-8";
            LC_NAME = "en_US.UTF-8";
            LC_NUMERIC = "en_US.UTF-8";
            LC_PAPER = "en_US.UTF-8";
            LC_TELEPHONE = "en_US.UTF-8";
            LC_TIME = "en_US.UTF-8";
          };
        };

        #---------- HARDWARE - GENERAL ----------#
        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
        hardware.enableRedistributableFirmware = lib.mkDefault true;
        hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
        hardware.bluetooth.enable = true;
        security.rtkit.enable = true;
        services.pulseaudio.enable = false;
        services.pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
        };

        #---------- HARDWARE - GRAPHICS ----------#
        hardware.graphics.enable = true;
        hardware.nvidia-container-toolkit.enable = true;
        services.xserver.videoDrivers = [ "nvidia" ];

        hardware.nvidia = {
          open = false;
          nvidiaSettings = true;
          nvidiaPersistenced = false;
          modesetting.enable = true;
          powerManagement.enable = false;
          powerManagement.finegrained = false;
        };

        xdg.portal = {
          enable = true;
          extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
          config.common.default = [
            "hyprland"
            "gtk"
          ];
        };

        #---------- HARDWARE - FILESYSTEMS ----------#
        swapDevices = [ ];
        fileSystems = {
          "/" = {
            device = "/dev/vg0/root";
            fsType = "ext4";
          };

          "/home/smissingham" = {
            device = "/dev/vg0/data";
            fsType = "ext4";
          };

          "/boot1" = {
            device = "/dev/nvme0n1p1";
            fsType = "vfat";
          };

          "/boot2" = {
            device = "/dev/nvme1n1p1";
            fsType = "vfat";
          };

          "/boot3" = {
            device = "/dev/nvme2n1p1";
            fsType = "vfat";
          };

          "/boot4" = {
            device = "/dev/nvme3n1p1";
            fsType = "vfat";
          };
        };

        #---------- SYSTEM - GENERAL ----------#
        programs.nix-ld.enable = true;
        environment.sessionVariables.NIX_LD_LIBRARY_PATH = lib.mkForce "/run/current-system/sw/share/nix-ld/lib";

        systemd.sleep.settings.Sleep = {
          AllowSuspend = "no";
          AllowHibernation = "no";
          AllowHybridSleep = "no";
          AllowSuspendThenHibernate = "no";
        };

        services.udev.extraRules = ''
          SUBSYSTEM=="usb", ATTRS{idVendor}=="3511", ATTRS{idProduct}=="2f06", DRIVER=="usbhid", ATTR{authorized}="0"
        '';

        #---------- SYSTEM - BOOT ----------#
        boot = {
          binfmt.emulatedSystems = [ "aarch64-linux" ];
          extraModulePackages = [ ];
          kernelModules = [ "kvm-intel" ];
          kernelParams = [ "boot.shell_on_fail" ];
          kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 0;

          loader = {
            efi.canTouchEfiVariables = true;
            grub = {
              enable = true;
              efiSupport = true;
              mirroredBoots = [
                {
                  path = "/boot1";
                  efiSysMountPoint = "/boot1";
                  devices = [ "nodev" ];
                }
                {
                  path = "/boot2";
                  efiSysMountPoint = "/boot2";
                  devices = [ "nodev" ];
                }
                {
                  path = "/boot3";
                  efiSysMountPoint = "/boot3";
                  devices = [ "nodev" ];
                }
                {
                  path = "/boot4";
                  efiSysMountPoint = "/boot4";
                  devices = [ "nodev" ];
                }
              ];
            };
          };

          initrd = {
            kernelModules = [ ];
            availableKernelModules = [
              "dm-mod"
              "xhci_pci"
              "ahci"
              "usbhid"
              "usb_storage"
              "sd_mod"
              "nvme"
              "md"
              "raid10"
              "md-mod"
            ];

            luks.devices."luksroot" = {
              device = "/dev/disk/by-id/md-uuid-${raidArrayUuid}";
              preLVM = true;
              allowDiscards = true;
            };
          };

          swraid = {
            enable = true;
            mdadmConf = ''
              MAILADDR nixosconfignotificat.flaccid440@passmail.net
              DEVICE /dev/nvme0n1p2 /dev/nvme1n1p2 /dev/nvme2n1p2 /dev/nvme3n1p2
              ARRAY /dev/md0 metadata=1.0 UUID=${raidArrayUuid}
            '';
          };
        };
      };
  };
}
