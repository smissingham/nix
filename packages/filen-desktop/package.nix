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
  npmBuildScript = "build:${(if pkgs.stdenv.isDarwin then "mac" else "linux")}";

  postPatch = ''
    chmod +w package-lock.json
    cp ${./package-lock.json} package-lock.json
  '';

  postInstall = ''
    # Install binary

    #ls -la $npmBuildDir/dist

    install -Dm755 $npmBuildDir/dist/filen-desktop $out/bin/filen-desktop

    # Install icon (verify source path in repository)
    install -Dm644 assets/icon.png $out/share/icons/hicolor/512x512/apps/filen-desktop.png

    # Create symbolic link for lower-resolution icon expectations
    mkdir -p $out/share/icons/hicolor/256x256/apps
    ln -s $out/share/icons/hicolor/512x512/apps/filen-desktop.png $out/share/icons/hicolor/256x256/apps/filen-desktop.png
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
