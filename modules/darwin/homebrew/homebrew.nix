{pkgs, config, ...}: {
  homebrew = {
    enable = true;

    global = {
      brewfile = true;
      autoUpdate = false;
    };

    prefix = "/opt/homebrew";
    
    casks = pkgs.callPackage ./casks.nix {};
    brews = pkgs.callPackage ./brews.nix {};
    masApps = {
      "Be Focused - Pomodoro Timer" = 973134470;
      "Microsoft Excel" = 462058435;   
    };
    
    onActivation = {
      cleanup = "uninstall";  # Uninstall packages removed from config for reproducibility
      autoUpdate = true;
      upgrade = true;
    };
    
    taps = builtins.attrNames config.nix-homebrew.taps;
  }; 
}
