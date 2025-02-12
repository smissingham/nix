{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
let
  ARRAY_UUID_NVME_R10 = "4d490828:49335c1f:f2730842:b4ff9746";
in
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

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
      ARRAY /dev/md0 metadata=1.2 UUID=${ARRAY_UUID_NVME_R10}
    '';
  };

  # define encrypted root filesystem on linux md raid array
  fileSystems."/" = {
    device = "/dev/mapper/luksraid";
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
      "luksraid" = {
        device = "/dev/disk/by-id/md-uuid-${ARRAY_UUID_NVME_R10}";
        preLVM = false; # If LUKS is on top of LVM, set this to true
        allowDiscards = true; # Optional, enables TRIM if supported by your SSD
      };
    };
  };

  swapDevices = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.kernelParams = [ "boot.shell_on_fail" ];
  boot.extraModulePackages = [ ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  networking.useDHCP = lib.mkDefault true;

  # #### NVIDIA CONFIG ####
  hardware.graphics.enable = true; # Enable OpenGL
  services.xserver.videoDrivers = [ "nvidia" ]; # Nvidia graphics driver
  hardware.nvidia-container-toolkit.enable = true; # Nvidia CDI support for docker/podman
  hardware.nvidia = {
    nvidiaPersistenced = true;
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    #package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  # #### WEBCAM CONFIG ####
  services.udev.extraRules =
    let
      camSettings = pkgs.writeShellScript "setup-v4l2.sh" ''
        ${pkgs.v4l-utils}/bin/v4l2-ctl \
          --device $1 \
          --set-fmt-video=width=1920,height=1080 \ # 1080p resolution
          -p 60 \ # Framerate to 60fps
          --set-ctrl=contrast=0 \
          --set-ctrl=brightness=30 \
          --set-ctrl=power_line_frequency=1 \ # Set to 50Hz power line compensation
      '';
    in
    ''
      SUBSYSTEM=="video4linux", KERNEL=="video[0-9]*", \
        ATTRS{product}=="Elgato Facecam MK.2 (USB2)", RUN="${camSettings} $devnode"
    '';
}
