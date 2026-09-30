{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
  makeWrapper,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "carbonyl";
  version = "0.0.3";

  # fathyb/carbonyl prebuilt (not in nixpkgs): Chromium rendered inside the terminal.
  src = fetchurl {
    url = "https://github.com/fathyb/carbonyl/releases/download/v${finalAttrs.version}/carbonyl.macos-arm64.zip";
    hash = "sha256-jPkZcmTY6pSo/50A7r812NCUx/hLhTDxvUH56q7ZgGQ=";
  };

  nativeBuildInputs = [
    unzip
    makeWrapper
  ];

  sourceRoot = "carbonyl-${finalAttrs.version}";

  # keep the upstream code signature intact
  dontStrip = true;
  dontFixup = true;

  # the binary loads its dylibs and icudtl.dat from its own directory
  installPhase = ''
    runHook preInstall
    mkdir -p $out/libexec/carbonyl
    cp -r . $out/libexec/carbonyl/
    makeWrapper $out/libexec/carbonyl/carbonyl $out/bin/carbonyl
    runHook postInstall
  '';

  meta = {
    description = "Chromium based browser built to run in a terminal";
    homepage = "https://github.com/fathyb/carbonyl";
    license = lib.licenses.bsd3;
    mainProgram = "carbonyl";
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
