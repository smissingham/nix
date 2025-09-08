{
  pkgs,
  pkgsUnstable,
  mainUser,
  ...
}:
{
  imports = [
    ./hardware.nix
    ./systemd.nix
  ];

  networking.hostName = "coeus";
  time.timeZone = "America/Chicago";

  mySharedModules = {
    browsers.floorp.enable = true;
    workflow.sops.enable = true;
    devtools = {
      smissingham-nvim.enable = true;
      smissingham-vscode.enable = true;
    };
  };

  myNixOSModules = {
    wm.plasma6.enable = true;
    #wm.gnome-xserver.enable = true;
    #wm.hyprland.enable = true;

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

  #----- Applications in User Space -----#
  home-manager.users.${mainUser.username}.home.packages = with pkgs; [
    pkgsUnstable.ghostty
    mypkgs.filen-desktop

    # Work
    teams-for-linux

    # Office
    libreoffice
  ];

  #----- Applications in System Space -----#
  environment.systemPackages = with pkgs; [
    cudaPackages.cudnn
  ];

  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 0;

  # Enable sound with pipewire.
  hardware.bluetooth.enable = true;
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
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
}
