{ inputs, ... }:
let
  pname = "vm-dev-oci";
in
{
  perSystem =
    { config, pkgs, ... }:
    let
      # needed for the custom krunvm fix overlay, to be removed once upstreamed
      mypkgs = inputs.mypkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};

      # default docker image from the nix flake to build & run if no specific image given
      defaultImage = config.packages.oci-devtools;
      importDefaultImage = pkgs.writeShellApplication {
        name = "${pname}-import-default-image";
        runtimeInputs = [ pkgs.skopeo ];
        text = ''
          image="localhost/${defaultImage.imageName}:${defaultImage.imageTag}"
          source="docker-archive:${defaultImage}:${defaultImage.imageName}:${defaultImage.imageTag}"
          destination="containers-storage:$image"

          skopeo copy --insecure-policy "$source" "$destination" >&2
          printf '%s\n' "$image"
        '';
      };
    in
    {
      packages.${pname} = pkgs.writeShellApplication {
        name = pname;

        runtimeEnv = {
          APP_NAME = pname;
          DEFAULT_OCI_IMAGE_IMPORT = "${importDefaultImage}/bin/${pname}-import-default-image";
        };

        runtimeInputs = [
          mypkgs.krunvm
          pkgs.nushell
        ];

        text = ''
          exec nu ${./mod.nu} "$@"
        '';
      };
    };
}
