{
  config,
  lib,
  modulesPath,
  mainUser,
  ...
}:
let
  # Dynamically fetch RAID array UUID using mdadm with fallback
  ARRAY_UUID_NVME_R10 = "15c09973:5a7c5d14:fbf6a709:77a116cb";
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    #./nvfancontrol.nix
  ];

  boot.loader = {
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

  # Setup RAID
  boot.swraid = {
    enable = true;
    mdadmConf = ''
      MAILADDR nixosconfignotificat.flaccid440@passmail.net
      DEVICE /dev/nvme0n1p2 /dev/nvme1n1p2 /dev/nvme2n1p2 /dev/nvme3n1p2
      ARRAY /dev/md0 metadata=1.0 UUID=${ARRAY_UUID_NVME_R10}
    '';
  };

  # define encrypted root filesystem inside LVM
  fileSystems."/" = {
    device = "/dev/vg0/root";
    fsType = "ext4";
  };

  # mount persisted encrypted data volume
  fileSystems."/home/${mainUser.username}" = {
    device = "/dev/vg0/data";
    fsType = "ext4";
  };

  # define redundant boot partitions
  fileSystems."/boot1" = {
    device = "/dev/nvme0n1p1";
    fsType = "vfat";
  };
  fileSystems."/boot2" = {
    device = "/dev/nvme1n1p1";
    fsType = "vfat";
  };
  fileSystems."/boot3" = {
    device = "/dev/nvme2n1p1";
    fsType = "vfat";
  };
  fileSystems."/boot4" = {
    device = "/dev/nvme3n1p1";
    fsType = "vfat";
  };

  # Ensure necessary kernel modules are available in initrd
  boot.initrd = {
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
    luks.devices = {
      "luksroot" = {
        device = "/dev/disk/by-id/md-uuid-${ARRAY_UUID_NVME_R10}";
        preLVM = true;
        allowDiscards = true;
      };
    };
  };

  swapDevices = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.kernelParams = [ "boot.shell_on_fail" ];
  boot.extraModulePackages = [ ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # #### NVIDIA CONFIG ####
  hardware.graphics.enable = true; # Enable OpenGL
  services.xserver.videoDrivers = [ "nvidia" ]; # Nvidia graphics driver
  hardware.nvidia-container-toolkit.enable = true; # Nvidia CDI support for docker/podman
  hardware.nvidia = {
    # TODO: This has broken recently, but was needed for the login screen to return after idle...
    nvidiaPersistenced = false;
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    #package = config.boot.kernelPackages.nvidiaPackages.beta;
  };
}
