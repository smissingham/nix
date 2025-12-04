{
  lib,
  pkgs,
  stdenv,
  fetchzip,
  unzip,
}:
let
  pname = "pfxpackage";
  version = "3";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchzip {
    url = "https://developer.pricefx.eu/pfxpackage/pricefx-pckg.zip";
    sha256 = "sha256-gB6IASJEqhHuwkO1HlpOpdLAVLBB95FXcqzaWKspgsg=";
    stripRoot = false;
  };

  nativeBuildInputs = [ unzip ];
  buildInputs = with pkgs; [
    jre17_minimal
  ];

  installPhase = ''
    runHook preInstall

    cd ./${pname}-*/

    cp -r . $out
    chmod +x $out/bin/pfxpackage

    runHook postInstall
  '';

  meta = with lib; {
    description = "PriceFX Configuration Fetch/Deploy tool";
    homepage = "https://developer.pricefx.eu/";
    license = licenses.unfree;
    platforms = platforms.all;
    maintainers = [ ];
  };
}
