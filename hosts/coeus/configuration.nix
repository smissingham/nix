{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hardware.nix
    ./systemd.nix
  ];

  environment.systemPackages = [ pkgs.cudaPackages.cudnn ];

  mySharedModules = {
    browsers = {
      floorp.enable = true;
    };
    devtools = {
      vscode.enable = true;
      nvim-smissingham.enable = true;
    };
    workflow = {
      #sops.enable = true;
    };
  };

  myNixOSModules = {
    # Window Manager
    wm = {
      plasma6.enable = true;
      #gnome-xserver.enable = true;
      #hyprland.enable = true;
    };

    entertainment.gaming.enable = true;

    access = {
      ssh.enable = true;
      fail2ban.enable = true;
      sunshine.enable = true;
      sunshine.withMoonlight = true;
      tailscale.enable = true;
      tailscale.authKey = "";
    };

    virt = {
      kvm = {
        enable = false;
        withCliTools = false;
        withGuiTools = false;
      };
      podman = {
        enable = true;
        dockerCompat = true;
        withCliTools = false;
        withGuiTools = true;
      };
    };
  };

  networking.hostName = "coeus";
  networking.useDHCP = lib.mkDefault true;

  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 0;

  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = {
            capslock = "esc";
            #esc = "capslock";
          };
        };
      };
    };
  };

  time.timeZone = "America/Chicago";

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  hardware.bluetooth.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Prevent all types of suspend/sleep. This is a server, and this only causes graphical issues
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  system.stateVersion = "25.05"; # Did you read the docs?
}
