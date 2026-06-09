{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "slack-cli";
  version = "4.1.0";

  # slackapi/slack-cli (official Slack Platform CLI), NOT nixpkgs' rockymadden slack-cli.
  src = fetchurl {
    url = "https://github.com/slackapi/slack-cli/releases/download/v${finalAttrs.version}/slack_cli_${finalAttrs.version}_macOS_arm64.tar.gz";
    hash = "sha256-L9BqRKbkR4OvAv8qODYO+ov/TGFN0x9zhLny9auoTCk=";
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/slack $out/bin/slack
    runHook postInstall
  '';

  meta = {
    description = "Slack Platform CLI for building and managing Slack apps";
    homepage = "https://github.com/slackapi/slack-cli";
    license = lib.licenses.mit;
    mainProgram = "slack";
    platforms = [ "aarch64-darwin" ];
  };
})
