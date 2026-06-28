{
  config,
  lib,
  ...
}:
let
  isDarwin = system: builtins.match ".*-darwin" system != null;

  hostModules =
    predicate:
    lib.mapAttrs (_: host: host.module) (
      lib.filterAttrs (
        _: host: builtins.isAttrs host && host ? system && host ? module && predicate host.system
      ) config.hosts
    );
in
{
  options.hosts = lib.mkOption {
    type = lib.types.attrs;
    default = { };
    description = "Host-specific modules exported by Dendritic.";
  };

  config = {
    flake = {
      nixosModules = hostModules (system: !isDarwin system);
      darwinModules = hostModules isDarwin;
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

          environment.enableAllTerminfo = true;
          environment.variables = {
            HOSTNAME = config.networking.hostName;
          };

          nix = {
            optimise.automatic = lib.mkDefault true;
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
