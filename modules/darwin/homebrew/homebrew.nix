{pkgs, config, ...}: {
  homebrew = {
    enable = true;

    global = {
      brewfile = true;
      autoUpdate = false;
    };

    brewPrefix = "/opt/homebrew/bin";
    
    casks = pkgs.callPackage ./casks.nix {};
    brews = pkgs.callPackage ./brews.nix {};
    masApps = {
      "Be Focused - Pomodoro Timer" = 973134470;
      "Microsoft Excel" = 462058435;   
    };
    
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };
    
    taps = builtins.attrNames config.nix-homebrew.taps;
  }; 
}
