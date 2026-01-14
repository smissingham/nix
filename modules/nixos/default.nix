# ----- DEFAULTS TO APPLY ONLY ON NIXOS SYSTEMS -----#
{
  mainUser,
  lib,
  ...
}:
{
  system.stateVersion = "25.05"; # Did you read the docs?

  networking = {
    useDHCP = lib.mkDefault true;
    firewall.enable = lib.mkDefault true;
    networkmanager.enable = lib.mkDefault true;
  };

  programs = {
    git.enable = true;
  };

  users.users.${mainUser.username} = {
    isNormalUser = true;
    description = mainUser.name;
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
