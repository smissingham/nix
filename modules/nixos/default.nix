# ----- DEFAULTS TO APPLY ONLY ON NIXOS SYSTEMS -----#
{
  mainUser,
  lib,
  pkgs,
  ...
}:
{

  # TODO implement dynamic discovery of all imports in modules directory
  imports = [
    ./home.nix
    ./packages.nix
    ./access/sunshine.nix
    ./access/tailscale.nix
    ./entertainment/gaming.nix
    ./virt/kvm.nix
    ./virt/podman.nix
    ./wm/gnome-xserver.nix
    ./wm/plasma6.nix
  ];

  programs.git.enable = true;
  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [ ];

  networking = {
    firewall.enable = true;
    networkmanager.enable = true;
  };

  users.users.${mainUser.username} = {
    isNormalUser = true;
    description = mainUser.name;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

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

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
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
}
