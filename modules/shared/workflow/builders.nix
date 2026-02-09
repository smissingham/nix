{
  config,
  pkgs,
  lib,
  mainUser,
  ...
}:
let
  moduleSet = "mySharedModules";
  moduleCategory = "workflow";
  moduleName = "builders";

  optionPath = [
    moduleSet
    moduleCategory
    moduleName
  ];
  enablePath = optionPath ++ [ "enable" ];
  systemsPath = optionPath ++ [ "systems" ];

  localHostName = config.networking.hostName;

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

  registeredHosts = builtins.filter (builder: builder.hostName != localHostName) builderHosts;

  builderStrings = builtins.map (
    builder:
    let
      systemString = builtins.concatStringsSep "," builder.systems;
    in
    "ssh-ng://${mainUser.username}@${builder.hostName} ${systemString} - - ${toString builder.maxJobs} ${toString builder.speedFactor}"
  ) registeredHosts;
in
{
  options = lib.setAttrByPath optionPath {
    enable = lib.mkEnableOption moduleName;
    systems = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Systems this host can build locally.";
    };
  };

  config = lib.mkIf (lib.getAttrFromPath enablePath config) (
    let
      rootGroup = if pkgs.stdenv.isDarwin then "wheel" else "root";
      userSshDir = "${mainUser.getHome { }}/.ssh";
      rootSshDir = "/var/root/.ssh";
      userKeyPath = "${userSshDir}/id_ed25519";
      userKnownHostsPath = "${userSshDir}/known_hosts";
      syncRootSshKeyScript = ''
        if [ -f "${userKeyPath}" ]; then
          mkdir -p "${rootSshDir}"
          chmod 700 "${rootSshDir}"
          cp "${userKeyPath}" "${rootSshDir}/id_ed25519"
          chmod 600 "${rootSshDir}/id_ed25519"
          chown root:${rootGroup} "${rootSshDir}/id_ed25519"
        fi

        if [ -f "${userKnownHostsPath}" ]; then
          mkdir -p "${rootSshDir}"
          cp "${userKnownHostsPath}" "${rootSshDir}/known_hosts"
          chmod 644 "${rootSshDir}/known_hosts"
          chown root:${rootGroup} "${rootSshDir}/known_hosts"
        fi
      '';
    in
    lib.mkMerge [
      {
        nix.settings = {
          builders = lib.mkForce builderStrings;
          builders-use-substitutes = true;
          extra-platforms = lib.getAttrFromPath systemsPath config;
          trusted-users = [
            "root"
            mainUser.username
          ];
        };

        environment.systemPackages = with pkgs; [
          nixpkgs-review
        ];
      }
      (lib.mkIf pkgs.stdenv.isDarwin {
        system.activationScripts.extraActivation.text = lib.mkAfter syncRootSshKeyScript;
      })
      (lib.mkIf (!pkgs.stdenv.isDarwin) {
        system.activationScripts.syncRootSshKey.text = syncRootSshKeyScript;
      })
    ]
  );
}
