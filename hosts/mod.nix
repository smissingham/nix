{
  config,
  lib,
  ...
}:
{
  options.hosts = lib.mkOption {
    type = lib.types.attrs;
    default = { };
    description = "Host-specific modules exported by Dendritic.";
  };

  config = {
    flake = {
      nixosModules.coeus = config.hosts.coeus.module;
      darwinModules.plutus = config.hosts.plutus.module;
    };

    hosts.shared =
      {
        config,
        pkgs,
        ...
      }:
      {
        config = {
          programs.zsh.enable = true;

          nixpkgs.config = {
            allowUnfree = true;
            allowUnfreePredicate = _: true;
          };

          environment.variables = {
            NIX_CONFIG_HOME = "${config.user.paths.home}/Documents/Nix";
            HOSTNAME = config.networking.hostName;
          };

          nix = {
            optimise.automatic = true;
            settings.experimental-features = [
              "nix-command"
              "flakes"
            ];
          };

          fonts.packages = [
            # Nerd/icon fonts
            pkgs.nerd-fonts.jetbrains-mono
            pkgs.nerd-fonts.ubuntu
            pkgs.font-awesome

            # Broad text and emoji fallback
            pkgs.noto-fonts
            pkgs.dejavu_fonts
            pkgs.liberation_ttf

            # UI and document families
            pkgs.inter
            pkgs.ibm-plex
            pkgs.source-sans
            pkgs.source-serif
            pkgs.libertinus
          ];

          environment.systemPackages = [
            pkgs.vim
          ];
        };
      };
  };
}
