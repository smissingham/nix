{ inputs, ... }:
let
  pname = "sm-herdr";
in
{
  perSystem =
    { config, pkgs, ... }:
    let
      herdr =
        inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.herdr;
    in
    {
      packages.${pname} = pkgs.writeShellApplication {
        name = pname;
        runtimeInputs = [
          herdr
          config.packages.sm-zsh
        ];
        text = ''
          export HERDR_CONFIG_PATH=${./config.toml}
          exec herdr "$@"
        '';
        meta.description = "Sean's wrapped Herdr agent multiplexer";
      };
    };
}
