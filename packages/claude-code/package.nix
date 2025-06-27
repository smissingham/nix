{
  lib,
  buildNpmPackage,
  fetchzip,
  nodejs_20,
}:

# borrowing from nixpkgs example: https://github.com/NixOS/nixpkgs/blob/nixos-25.05/pkgs/by-name/cl/claude-code/package.nix#L39
buildNpmPackage rec {
  pname = "claude-code";
  version = "1.0.35";

  nodejs = nodejs_20; # required for sandboxed Nix builds on Darwin

  src = fetchzip {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
    hash = "sha256-Lt79XxHrgy6rPAHBf1QtwjsKnrZmsKFeVFOvHwN4aOY=";
  };

  npmDepsHash = "sha256-1iwGpNk3s9UcqpbB/ljTHJoi/RbMUsIKbNh1Q2wRxkw=";

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  dontNpmBuild = true;

  AUTHORIZED = "1";

  # `claude-code` tries to auto-update by default, this disables that functionality.
  # https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/overview#environment-variables
  postInstall = ''
    wrapProgram $out/bin/claude \
      --set DISABLE_AUTOUPDATER 1
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "An agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster";
    homepage = "https://github.com/anthropics/claude-code";
    downloadPage = "https://www.npmjs.com/package/@anthropic-ai/claude-code";
    license = lib.licenses.unfree;
    maintainers = [ lib.maintainers.malo ];
    mainProgram = "claude";
  };
}
