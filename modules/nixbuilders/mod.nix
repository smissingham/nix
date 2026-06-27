{ lib, ... }:
let
  builderHosts = [
    {
      hostName = "plutus";
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      maxJobs = 4;
      speedFactor = 1;
    }
    {
      hostName = "coeus";
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      maxJobs = 4;
      speedFactor = 1;
    }
  ];
in
{
  modules.shared.nixbuilders =
    { config, pkgs, ... }:
    let
      cfg = config.nixbuilders;
      remoteBuilders = lib.filter (builder: builder.hostName != config.networking.hostName) builderHosts;

      builderStrings = map (
        builder:
        let
          systems = lib.concatStringsSep "," builder.systems;
        in
        "ssh-ng://${config.user.username}@${builder.hostName} ${systems} - - ${toString builder.maxJobs} ${toString builder.speedFactor}"
      ) remoteBuilders;

      userSshDir = "${config.user.paths.home}/.ssh";
      userKey = "${userSshDir}/id_ed25519";
      userHosts = "${userSshDir}/known_hosts";

      copyKeyScript = rootSshDir: rootGroup: ''
        if [ -f "${userKey}" ]; then
          mkdir -p "${rootSshDir}"
          chmod 700 "${rootSshDir}"
          cp "${userKey}" "${rootSshDir}/id_ed25519"
          chmod 600 "${rootSshDir}/id_ed25519"
          chown root:${rootGroup} "${rootSshDir}/id_ed25519"
        fi

        if [ -f "${userHosts}" ]; then
          mkdir -p "${rootSshDir}"
          cp "${userHosts}" "${rootSshDir}/known_hosts"
          chmod 644 "${rootSshDir}/known_hosts"
          chown root:${rootGroup} "${rootSshDir}/known_hosts"
        fi
      '';
    in
    {
      options.nixbuilders = {
        enable = lib.mkEnableOption "remote Nix builders";

        systems = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Systems this host can build locally.";
        };
      };

      config = lib.mkIf cfg.enable (
        lib.mkMerge [
          {
            nix.settings = {
              builders = lib.mkForce builderStrings;
              builders-use-substitutes = true;
              extra-platforms = cfg.systems;
              trusted-users = [
                "root"
                config.user.username
              ];
            };

            environment.systemPackages = [ pkgs.nixpkgs-review ];
          }
          (lib.mkIf pkgs.stdenv.isDarwin {
            system.activationScripts.extraActivation.text = lib.mkAfter (
              copyKeyScript "/var/root/.ssh" "wheel"
            );
          })
          (lib.mkIf pkgs.stdenv.isLinux {
            system.activationScripts.syncRootSshKey.text = copyKeyScript "/root/.ssh" "root";
          })
        ]
      );
    };
}
