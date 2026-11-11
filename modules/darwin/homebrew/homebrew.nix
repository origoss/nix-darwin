{
  pkgs,
  config,
  lib,
  ...
}:
let
  # Non-official taps in brew's short form ("nikitabobko/homebrew-aerospace" -> "nikitabobko/aerospace").
  thirdPartyTaps = map (lib.replaceStrings [ "/homebrew-" ] [ "/" ]) (
    lib.filter (n: !lib.hasPrefix "homebrew/" n) (builtins.attrNames config.nix-homebrew.taps)
  );
in
{
  # brew refuses casks/formulae from untrusted taps; trust ours before `brew bundle` runs.
  system.activationScripts.preActivation.text = ''
    sudo --user=${config.nix-homebrew.user} --set-home env HOMEBREW_NO_AUTO_UPDATE=1 \
      /opt/homebrew/bin/brew trust --quiet --tap ${lib.escapeShellArgs thirdPartyTaps} || true
  '';

  homebrew = {
    enable = true;

    global = {
      brewfile = true;
      autoUpdate = false;
    };

    prefix = "/opt/homebrew";

    casks = pkgs.callPackage ./casks.nix { };
    brews = pkgs.callPackage ./brews.nix { };
    masApps = {
      "Be Focused - Pomodoro Timer" = 973134470;
    };

    onActivation = {
      cleanup = "uninstall"; # Uninstall packages removed from config for reproducibility
      autoUpdate = true;
      # upgrade left off: force-upgrading every cask on rebuild breaks on casks
      # whose uninstall scripts need interactive sudo (e.g. virtualbox).
    };

    taps = builtins.attrNames config.nix-homebrew.taps;
  };
}
