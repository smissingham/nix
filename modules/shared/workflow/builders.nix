{
  config,
  pkgs,
  lib,
  mainUser,
  ...
}:
let
  cfg = config.mySharedModules.workflow.builders;

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

  remoteBuilders = lib.filter (b: b.hostName != config.networking.hostName) builderHosts;

  builderStrings = map (
    b:
    let
      systems = lib.concatStringsSep "," b.systems;
    in
    "ssh-ng://${mainUser.username}@${b.hostName} ${systems} - - ${toString b.maxJobs} ${toString b.speedFactor}"
  ) remoteBuilders;

  userSshDir = "${mainUser.getHome { }}/.ssh";
  userKey = "${userSshDir}/id_ed25519";
  userHosts = "${userSshDir}/known_hosts";

  copyKeyScript =
    rootSshDir: rootGroup:
    lib.concatStringsSep "\n" [
      ''
        if [ -f "${userKey}" ]; then
          mkdir -p "${rootSshDir}"
          chmod 700 "${rootSshDir}"
          cp "${userKey}" "${rootSshDir}/id_ed25519"
          chmod 600 "${rootSshDir}/id_ed25519"
          chown root:${rootGroup} "${rootSshDir}/id_ed25519"
        fi
      ''
      ''
        if [ -f "${userHosts}" ]; then
          mkdir -p "${rootSshDir}"
          cp "${userHosts}" "${rootSshDir}/known_hosts"
          chmod 644 "${rootSshDir}/known_hosts"
          chown root:${rootGroup} "${rootSshDir}/known_hosts"
        fi
      ''
    ];
in
{
  options.mySharedModules.workflow.builders = {
    enable = lib.mkEnableOption "remote builders";
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
            mainUser.username
          ];
        };

        environment.systemPackages = [ pkgs.nixpkgs-review ];
      }
      (lib.mkIf pkgs.stdenv.isDarwin {
        system.activationScripts.extraActivation.text = lib.mkAfter (
          copyKeyScript "/var/root/.ssh" "wheel"
        );
      })
      (lib.mkIf (!pkgs.stdenv.isDarwin) {
        system.activationScripts.syncRootSshKey.text = copyKeyScript "/root/.ssh" "root";
      })
    ]
  );
}
