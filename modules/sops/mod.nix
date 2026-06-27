{ inputs, ... }:
let
  sops = inputs.wrapper-modules.lib.wrapModule ../../wrappers/sops.nix;
in
{
  modules.shared.sops =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.sops;
      home = config.users.users.${config.user.username}.home;
    in
    {
      options.sops.enable = lib.mkEnableOption "SOPS command-line tools";

      config.environment.systemPackages = lib.mkIf cfg.enable [
        (sops.wrap {
          inherit pkgs;
          aliases = [ "sm-sops" ];
          runtimePkgs = [ pkgs.age-plugin-yubikey ];

          age.keyFile = "${home}/.config/sops/keys.txt";
          configFile.content = builtins.readFile ./.sops.yaml;
        })
      ];
    };
}
