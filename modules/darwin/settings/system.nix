{self, ...}: {
  security.pam.services.sudo_local.touchIdAuth = true;
  system = {
    configurationRevision = self.rev or self.dirtyRev or null;
    checks.verifyNixPath = false;

    primaryUser = "eja";

    defaults = {
      NSGlobalDomain = {
      AppleShowAllExtensions = true;
      ApplePressAndHoldEnabled = false;
      AppleShowAllFiles = true;
      AppleICUForce24HourTime = true;
      AppleInterfaceStyleSwitchesAutomatically = true;
      AppleEnableMouseSwipeNavigateWithScrolls = true;
      AppleEnableSwipeNavigateWithScrolls = true;
      NSAutomaticWindowAnimationsEnabled = true;

      KeyRepeat = 2; # Values: 120, 90, 60, 30, 12, 6, 2
      InitialKeyRepeat = 15; # Values: 120, 94, 68, 35, 25, 15

      "com.apple.mouse.tapBehavior" = 1;
      "com.apple.sound.beep.volume" = 0.0;
      "com.apple.sound.beep.feedback" = 0;
      "com.apple.trackpad.scaling" = 3.0;
      };

      dock = {
      autohide = true;
      show-recents = false;
      launchanim = true;
      orientation = "bottom";
      tilesize = 48;
      persistent-apps = [
          "/System/Applications/Calendar.app/"
          "/Applications/Google\ Chrome.app"
          "/Applications/iTerm.app"
          "/Applications/Visual\ Studio\ Code.app"
      ];
      };

      finder = {
      _FXShowPosixPathInTitle = false;
      };

      trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
      };
    };
  };
}