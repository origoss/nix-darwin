{ pkgs, config, ... }:
{
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
