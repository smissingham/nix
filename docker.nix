{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  # DOCKER CONFIG, Doesn't support CDI on 24.11.
  # Switching to podman.
  # Ref: https://github.com/NixOS/nixpkgs/issues/337873
  #virtualisation.docker.enable = true;
  #hardware.nvidia-container-toolkit.enable = true;
  #virtualisation.docker.rootless = {
  #  enable = true;
  #  setSocketVariable = true;
  #};
  #environment.systemPackages = with pkgs; [
  #  docker-compose
  #];

  # Enable common container config files in /etc/containers
  virtualisation.containers.enable = true;

  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;

      autoPrune.enable = true;
    };
  };

  networking.firewall.interfaces."podman+".allowedUDPPorts = [53 5353];

  # Useful other development tools
  environment.systemPackages = with pkgs; [
    dive # look into docker image layers
    podman-tui # status of containers in the terminal
    #docker-compose # start group of containers for dev
    podman-compose # start group of containers for dev
  ];
}
