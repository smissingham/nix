{
  lib,
  stdenvNoCC,
  openjdk,
  makeWrapper,
  ...
}:

stdenvNoCC.mkDerivation {
  pname = "groovyls";
  version = "unstable-2024-06-28";

  # Use pre-built JAR from the package directory
  # This JAR was built from: https://github.com/GroovyLanguageServer/groovy-language-server
  # Commit: 7be0244a1a58a144c382ee95a22fcc7ce9662706
  src = ./groovy-language-server-all.jar;

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/share/java
    cp $src $out/share/java/groovyls.jar

    mkdir -p $out/bin
    makeWrapper ${openjdk}/bin/java $out/bin/groovyls \
      --add-flags "-jar $out/share/java/groovyls.jar"
  '';

  meta = {
    description = "Groovy Language Server";
    homepage = "https://github.com/GroovyLanguageServer/groovy-language-server";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "groovyls";
    platforms = lib.platforms.all;
    longDescription = ''
      Groovy Language Server implementation.

      Note: This package uses a pre-built JAR file because building from source
      requires gradle with network access during build time, which is complex to
      handle in Nix. The JAR was built from commit 7be0244 of the upstream repository.
    '';
  };
}
