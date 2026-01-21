{
  pkgs,
  lib,
  mainUser,
  ...
}:
{
  imports = [
    ./hardware.nix
    ./systemd.nix
  ];

  networking.hostName = "coeus";
  networking.extraHosts = ''
    127.0.0.1 db padb redis yugabyte
  '';
  time.timeZone = "America/Chicago";

  myPrivateModules = {
    backup.syncthing.enable = true;
  };

  mySharedModules = {
    browsers.floorp.enable = true;
    workflow = {
      sops.enable = true;
    };
    devtools = {
      terminals.enable = true;
      tmux.enable = true;
      smissingham-nvim.enable = true;
      smissingham-vscode.enable = true;
    };
  };

  myNixOSModules = {
    #wm.plasma6.enable = true;
    #wm.gnome-xserver.enable = true;
    wm.hyprland.enable = true;
    stylix.enable = true;

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
        enable = true;
        withCliTools = true;
        withGuiTools = true;
      };
      podman = {
        enable = true;
        dockerCompat = true;
        withCliTools = false;
        withGuiTools = true;
      };
    };
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  #----- Applications in User Space -----#
  home-manager.users.${mainUser.username}.home.packages = with pkgs; [

    # Personal Workflow
    mynixpkgs.filen-desktop
    spotify
    obsidian
    chromium

    # comms
    signal-desktop
    vesktop

    # Productivity
    #libreoffice
    onlyoffice-bin

    # Dev
    #jetbrains.idea-oss
    mynixpkgs.surrealist
  ];
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      uv
      bun
      nodejs_24
      cudaPackages.cudnn
      cudaPackages.cuda_cudart
      libGLU
    ];
  };
  environment.sessionVariables.NIX_LD_LIBRARY_PATH = lib.mkForce "/run/current-system/sw/share/nix-ld/lib:/run/opengl-driver/lib";

  #----- Applications in System Space -----#
  environment.systemPackages = with pkgs; [
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

  # Shokz OpenComm2 USB dongle fix - prevents triggering standby/sleep
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="3511", ATTRS{idProduct}=="2f06", DRIVER=="usbhid", ATTR{authorized}="0" 
  '';
}
