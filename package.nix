{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  nodejs_22,
  ripgrep,
}:

let
  # Written by update.sh from the npm registry.
  release = lib.importJSON ./release.json;
in
stdenvNoCC.mkDerivation {
  pname = "gemini-cli";
  inherit (release) version;

  # The npm tarball ships a prebuilt esbuild bundle (bundle/gemini.js), so
  # there is nothing to build and no npm dependency tree to fetch.
  src = fetchurl {
    inherit (release) url hash;
  };

  sourceRoot = "package";

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/gemini-cli $out/bin
    cp -r bundle package.json LICENSE $out/share/gemini-cli/

    makeWrapper ${lib.getExe nodejs_22} $out/bin/gemini \
      --add-flags "--no-warnings=DEP0040" \
      --add-flags "$out/share/gemini-cli/bundle/gemini.js" \
      --prefix PATH : ${lib.makeBinPath [ ripgrep ]}

    runHook postInstall
  '';

  meta = {
    description = "AI agent that brings the power of Gemini directly into your terminal";
    homepage = "https://github.com/google-gemini/gemini-cli";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    platforms = lib.platforms.linux;
    mainProgram = "gemini";
  };
}
