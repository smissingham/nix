{ inputs, ... }:
let
  pname = "sm-opencode";
in
{
  perSystem =
    { pkgs, ... }:
    {
      # sops-wrapper to embed secrets in process-env
      packages.${pname} = inputs.wrapper-modules.wrappers.sops.wrap {
        inherit pkgs;

        binName = pname;
        aliases = [ "opencode" ];

        age.yubikey = true;
        secrets.file = ./sops/secrets.env;
        secrets.env.export.all = true;

        settings.creation_rules = [
          {
            path_regex = ".*";
            key_groups = [
              {
                age = [
                  "age1yubikey1qtpugaket6nqs3ezudp7w5n0h8xdwhdawsf6rus4ctfm249g5kg7vxm7egz"
                  "age1yubikey1q08jxsggfcsrvcjaq8kvnl4mxwnlnqx3wwxwlcwx30x6rxleh20rzdv0pep"
                ];
              }
            ];
          }
        ];

        # inner opencode wrapper
        package = inputs.wrapper-modules.wrappers.opencode.wrap {
          inherit pkgs;
          package = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.opencode;
          aliases = [ pname ];

          env.OPENCODE_CONFIG_DIR = ./.;
          tui-settings = ./tui.json |> builtins.readFile |> builtins.fromJSON;
        };
      };
    };
}
