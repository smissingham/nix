{
  lib,
  pkgs,
  buildNpmPackage,
  fetchFromGitHub,
  makeDesktopItem,
}:

buildNpmPackage rec {
  pname = "filen-desktop";
  version = "3.0.41";
  makeCacheWritable = true;

  src = fetchFromGitHub {
    owner = "FilenCloudDienste";
    repo = "filen-desktop";
    rev = "v${version}";
    hash = "sha256-HpyASSpjRgBTkV7L5bfi65rO+MnrSP7VdeuL/VXBlSo=";
  };

  npmDepsHash = "sha256-uePTd8y26hyLYcazlrOyrH+7CRjav+/d6HLMSKEGWiA=";
  npmBuildScript = "build";
  dontNpmBuild = true; # Skip the electron-builder build step

  # Add environment variables to prevent Electron from downloading
  ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
  PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";

  # Add electron as a build dependency
  buildInputs = [ pkgs.electron ];

  postPatch = ''
    chmod +w package-lock.json
    cp ${./package-lock.json} package-lock.json

    # If needed, you can add a patch to make the build use the system electron
    # This depends on how the project is structured
    substituteInPlace package.json \
      --replace '"electron": "^33.2.0"' '"electron": "*"'
      
    # Modify package.json to disable electron-builder in the build script
    substituteInPlace package.json \
      --replace '"build:linux": "npm run build && electron-builder -l --publish never"' '"build:linux": "npm run build"'
  '';

  postBuild = ''
    # Run the TypeScript build
    npm run clear
    npm run lint
    npm run tsc
  '';

  postInstall = ''
    # Install executable wrapper script
    mkdir -p $out/bin
    cat > $out/bin/filen-desktop <<EOF
    #!/bin/sh
    exec ${pkgs.electron}/bin/electron $out/lib/node_modules/@filen/desktop/dist
    EOF
    chmod +x $out/bin/filen-desktop

    # Install icons of all available sizes from the /icons/png folder
    for size in 16 24 32 48 64 96 128 256 512 1024; do
      if [ -f "$src/build/icons/png/''${size}x''${size}.png" ]; then
        mkdir -p $out/share/icons/hicolor/''${size}x''${size}/apps
        cp $src/build/icons/png/''${size}x''${size}.png $out/share/icons/hicolor/''${size}x''${size}/apps/filen-desktop.png
      fi
    done
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "filen-desktop";
      exec = "filen-desktop";
      icon = "filen-desktop";
      desktopName = "Filen Desktop";
      genericName = "Encrypted Cloud Storage";
      comment = "Secure cloud storage client";
      categories = [
        "Network"
        "FileTransfer"
        "Utility"
      ];
      keywords = [
        "cloud"
        "storage"
        "encrypted"
      ];
    })
  ];

  meta = with lib; {
    homepage = "https://filen.io/products";
    downloadPage = "https://filen.io/products/desktop";
    description = "Filen Desktop Client";
    longDescription = ''
      Encrypted Cloud Storage built for your Desktop.
      Sync your data, mount network drives, collaborate with others and access files natively — 
      powered by robust encryption and seamless integration.
    '';
    mainProgram = "filen-desktop";
    platforms = platforms.linux ++ platforms.darwin;
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ smissingham ];
  };
}
