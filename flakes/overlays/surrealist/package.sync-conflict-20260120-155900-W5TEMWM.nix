{
  lib,
  pkgs,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  buildGoModule,
}:
let
  pname = "surrealist";
  version = "3.6.15";
  appName = "Surrealist";

  esbuild =
    let
      version = "0.21.5";
    in
    pkgs.esbuild.override {
      buildGoModule =
        args:
        buildGoModule (
          args
          // {
            inherit version;
            src = fetchFromGitHub {
              owner = "evanw";
              repo = "esbuild";
              rev = "v${version}";
              hash = "sha256-FpvXWIlt67G8w3pBKZo/mcp57LunxDmRUaCU/Ne89B8=";
            };
            vendorHash = "sha256-+BfxCyg0KkDQpHt/wycy/8CTG6YBA/VJvJFhhzUnSiQ=";
          }
        );
    };
in
stdenv.mkDerivation (finalAttrs: {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "surrealdb";
    repo = "surrealist";
    rev = "surrealist-v${finalAttrs.version}";
    hash = "sha256-AsA5p3ViwtBUBOw8Bj4okGsy3ImCcSz7Ctd0WJ2wBkE=";
  };

  env = {
    ESBUILD_BINARY_PATH = lib.getExe esbuild;
    # OPENSSL_NO_VENDOR = 1;
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    src = "${finalAttrs.src}/src-tauri";
    hash = "sha256-NhgSfiBb4FGEnirpDFWI3MIMElen8frKDFKmCBJlSBY=";
  };

  cargoRoot = "src-tauri";
  buildAndTestSubdir = finalAttrs.cargoRoot;

  nativeBuildInputs = [
    pkgs.cargo-tauri.hook
    pkgs.jq
    pkgs.moreutils
    pkgs.bun
    pkgs.cargo
    pkgs.pkg-config
    pkgs.rustc
    rustPlatform.cargoSetupHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    pkgs.gobject-introspection
    pkgs.makeBinaryWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    pkgs.makeWrapper
  ];

  buildInputs = [
    pkgs.cairo
    pkgs.openssl
    pkgs.pango
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    pkgs.gdk-pixbuf
    pkgs.glib-networking
    pkgs.libsoup_3
    pkgs.webkitgtk_4_1
  ];

  postPatch = ''
    jq '
      .bundle.targets = ["app"] |
      .bundle.createUpdaterArtifacts = false |
      .plugins.updater = {"active": false, "pubkey": "", "endpoints": []}
    ' \
    src-tauri/tauri.conf.json | sponge src-tauri/tauri.conf.json
  '';

  buildPhase = ''
    runHook preBuild

    bun install --frozen-lockfile
    bun run tauri:build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    ${
      if stdenv.hostPlatform.isDarwin then
        ''
          mkdir -p $out/Applications
          cp -r src-tauri/target/release/bundle/macos/${appName}.app $out/Applications/

          mkdir -p $out/bin
          makeWrapper "$out/Applications/${appName}.app/Contents/MacOS/${appName}" $out/bin/${pname}
        ''
      else
        ''
          mkdir -p $out/bin
          cp src-tauri/target/release/surrealist $out/bin/
        ''
    }

    runHook postInstall
  '';

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    wrapProgram "$out/bin/surrealist" \
      --set GIO_EXTRA_MODULES ${pkgs.glib-networking}/lib/gio/modules \
      --set WEBKIT_DISABLE_COMPOSITING_MODE 1
  '';

  meta = {
    description = "Visual management of your SurrealDB database";
    homepage = "https://surrealdb.com";
    downloadPage = "https://github.com/surrealdb/surrealist";
    license = lib.licenses.mit;
    mainProgram = "surrealist";
    maintainers = with lib.maintainers; [ smissingham ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
