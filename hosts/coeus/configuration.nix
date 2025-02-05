{ pkgs, mainUser, ... }:
{
  imports = [
    ../../styles/catppuccin-mocha.nix
    ./hardware.nix
    ./systemd.nix
  ];

  mySystemModules = {
    # Window Manager
    wm.plasma6.enable = true;
    #wm.gnome-xserver.enable = true;
    entertainment.gaming.enable = true;

    access = {
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
        enable = false;
        dockerCompat = false;
        withCliTools = false;
        withGuiTools = false;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    # System Utilities
    v4l-utils
  ];

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

  home-manager.users.${mainUser.username}.home.packages = with pkgs; [
    #floorp
    firefox

    # Work
    teams-for-linux

    # Office
    libreoffice
    thunderbird
    filen-desktop

    # Dev Tools
    kdePackages.kate
    jetbrains-toolbox
  ];

  # Configure networking
  networking.hostName = "coeus";
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

  system.stateVersion = "24.11"; # Did you read the docs?
}
