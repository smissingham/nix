{ lib, ... }:
{
  modules.shared.nixbuilders =
    {
      config,
      options,
      pkgs,
      pkgsstable,
      ...
    }:
    let
      cfg = config.nixbuilders;
      isLinuxSystem = system: builtins.match ".*-linux" system != null;
      hasLinuxSystem = builtins.any isLinuxSystem cfg.systems;
      extraPlatforms =
        if pkgs.stdenv.hostPlatform.isDarwin then
          builtins.filter (system: !isLinuxSystem system) cfg.systems
        else
          cfg.systems;
    in
    {
      options.nixbuilders = {
        enable = lib.mkEnableOption "local Nix builder setup";

        systems = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Systems to configure locally; Linux systems enable nix-darwin's Linux builder on Darwin.";
        };
      };

      config = lib.mkIf cfg.enable (
        lib.mkMerge [
          {
            nix.settings = {
              extra-platforms = extraPlatforms;
              trusted-users = [
                "root"
                config.user.username
              ];
            };

            environment.systemPackages = [ pkgs.nixpkgs-review ];
          }

          (lib.optionalAttrs (options.nix ? linux-builder) {
            nix.linux-builder = lib.mkIf hasLinuxSystem {
              enable = true;
              package = pkgs.darwin.linux-builder.override {
                modules = [
                  ({ lib, ... }: {
                    virtualisation.host.pkgs = lib.mkForce pkgsstable;
                  })
                ];
              };
              ephemeral = true;
              maxJobs = 4;
              speedFactor = 1;
              config.virtualisation = {
                cores = 4;
                darwin-builder = {
                  diskSize = 40 * 1024;
                  memorySize = 4 * 1024;
                };
              };
            };

            environment.etc."ssh/ssh_known_hosts".text = lib.mkIf hasLinuxSystem ''
              linux-builder ${
                builtins.readFile
                  config.nix.linux-builder.package.nixosConfig.environment.etc."ssh/ssh_host_ed25519_key.pub".source
              }
            '';
          })
        ]
      );
    };
}
