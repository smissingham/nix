{
  lib,
  pkgs,
  buildNpmPackage,
  fetchFromGitHub,
  makeDesktopItem,
}:
let
  desktopItem = makeDesktopItem {
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
  };
in

buildNpmPackage rec {
  pname = "filen-desktop";
  version = "3.0.47";
  makeCacheWritable = true;

  src = fetchFromGitHub {
    owner = "FilenCloudDienste";
    repo = "filen-desktop";
    rev = "v${version}";
    hash = "sha256-WS9JqErfsRtt6zF+LrKkpiscJ25MRXmRxmIm3GH6xf0=";
  };

  npmDepsHash = "sha256-W2xJDUAJHQHYMiurCMlWbIzjddUywB2whItuBmj5Nr8=";
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

    # Override package-lock.json electron version to use whatever it's given by nixpkgs
    substituteInPlace package.json \
      --replace-fail '"electron": "^34.1.1"' '"electron": "*"'

    # Prevent electron-builder in package.json scripts
    substituteInPlace package.json \
      --replace-fail '&& electron-builder ' ' '
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
    cp -rt $out/bin ${desktopItem}/share/applications 

    # Install icons of all available sizes from the /icons/png folder
    for size in 16 24 32 48 64 96 128 256 512 1024; do
      if [ -f "$src/build/icons/png/''${size}x''${size}.png" ]; then
        mkdir -p $out/share/icons/hicolor/''${size}x''${size}/apps
        cp $src/build/icons/png/''${size}x''${size}.png $out/share/icons/hicolor/''${size}x''${size}/apps/filen-desktop.png
      fi
    done
  '';

  # This ensures the desktop item is correctly handled
  nativeBuildInputs = [ pkgs.copyDesktopItems ];

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
