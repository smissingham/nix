{ inputs, ... }:
let
  pname = "vm-dev-oci";
  # Writable directory shares, relative to the host and guest homes.
  hostPaths = [
    ".local/share/opencode"
    ".local/state/opencode"
  ];
in
{
  perSystem =
    { config, pkgs, ... }:
    let
      # needed for the custom krunvm fix overlay, to be removed once upstreamed
      mypkgs = inputs.mypkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
      cpkgs =
        inputs.nixpkgs.legacyPackages.${
          pkgs.lib.replaceStrings [ "darwin" ] [ "linux" ] pkgs.stdenv.hostPlatform.system
        };

      # The upstream kernel bundle avoids bootstrapping Linux through krunvm on Darwin.
      libkrunfwDarwin = mypkgs.stdenv.mkDerivation {
        pname = "libkrunfw";
        version = "5.5.0";
        src = mypkgs.fetchurl {
          url = "https://github.com/libkrun/libkrunfw/releases/download/v5.5.0/libkrunfw-prebuilt-aarch64.tgz";
          hash = "sha256-W/rm7+5j298EqPrCpp13LZ+QCvL1TEQptKzf1thrmXk=";
        };
        makeFlags = [ "PREFIX=$(out)" ];
      };

      # default docker image from the nix flake to build & run if no specific image given
      defaultImage = config.packages.oci-devtools.override (old: {
        # krunvm's macOS volume helper needs /bin/sh and mount in the image.
        copyToRoot = cpkgs.buildEnv {
          name = "${pname}-root";
          paths = [
            old.copyToRoot
            cpkgs.bash
            cpkgs.util-linux
          ];
          pathsToLink = [ "/" ];
        };
        config = old.config // {
          Env =
            builtins.filter (value: !pkgs.lib.hasPrefix "PATH=" value) old.config.Env
            ++ [ "PATH=/bin" ];
        };
      });
      importDefaultImage = pkgs.writeShellApplication {
        name = "${pname}-import-default-image";
        runtimeInputs = [ pkgs.skopeo ];
        text = ''
          image="localhost/${defaultImage.imageName}:${defaultImage.imageTag}"
          source="docker-archive:${defaultImage}:${defaultImage.imageName}:${defaultImage.imageTag}"
          destination="containers-storage:${pkgs.lib.optionalString pkgs.stdenv.hostPlatform.isDarwin "[vfs@/Volumes/krunvm/root+/Volumes/krunvm/runroot]"}$image"

          skopeo --override-os linux copy --insecure-policy "$source" "$destination" >&2
          printf '%s\n' "$image"
        '';
      };
    in
    {
      packages.${pname} = pkgs.writeShellApplication {
        name = pname;

        runtimeEnv = {
          APP_NAME = pname;
          HOST_PATHS = builtins.toJSON hostPaths;
          DEFAULT_OCI_IMAGE_IMPORT = "${importDefaultImage}/bin/${pname}-import-default-image";
        };

        runtimeInputs = [
          (
            (mypkgs.krunvm.override (
              pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
                # OCI roots need the bundled Linux kernel, not the EFI boot variant.
                libkrun-efi =
                  (mypkgs.libkrun-efi.override { withGpu = false; }).overrideAttrs
                    (old: {
                      pname = "libkrun";
                      buildInputs = [ ];
                      makeFlags = builtins.filter (flag: flag != "EFI=1") old.makeFlags;
                      postInstall = "";
                      postPatch = old.postPatch + ''
                        substituteInPlace Makefile --replace-fail \
                          'mv target/release/libkrun.dylib target/release/$(KRUN_BASE_$(OS))' \
                          ':'
                        substituteInPlace src/libkrun/src/lib.rs --replace-fail \
                          'libkrunfw.5.dylib' \
                          '${libkrunfwDarwin}/lib/libkrunfw.5.dylib'
                      '';
                    });
              }
            )).overrideAttrs
            (old: {
              # Keep krunvm's native mounts, but allow nested home directories.
              postPatch = old.postPatch + ''
                substituteInPlace src/utils.rs --replace-fail \
                  'guest_path.components().count() != 2' \
                  'guest_path.components().count() < 2'
                substituteInPlace src/commands/start.rs --replace-fail \
                  'std::fs::create_dir(full_guest_path)' \
                  'std::fs::create_dir_all(full_guest_path)' \
                  --replace-fail \
                  'let ret = unsafe { libc::mkdir(guest_dir.as_ptr(), 0o755) };' \
                  'let ret = std::fs::create_dir_all(format!("{}{}", rootfs, guest_path)).map(|_| 0).expect("Could not create guest mount directory");'
              '';
            })
          )
          pkgs.nushell
        ];

        text = ''
          exec nu ${./mod.nu} "$@"
        '';
      };
    };
}
