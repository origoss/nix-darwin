{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, mac-app-util, nix-homebrew, homebrew-core, homebrew-cask, home-manager, ... }:
  let
    configuration = { pkgs, config, lib, ... }: {

      nixpkgs = {
        config = {
          allowUnfree = true;
          allowBroken = true;
          allowInsecure = false;
          allowUnsupportedSystem = false;
         };
      };
      
      security.pam.services.sudo_local.touchIdAuth = true;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs; [] ++ (import ./packages.nix { inherit pkgs; });

      homebrew = {
        enable = true;
        casks = pkgs.callPackage ./casks.nix {};
        brews = [
          "mas"
          "kube-ps1"
        ];
        masApps = {
          "WhatsApp Messenger" = 310633997;                              
          "Be Focused - Pomodoro Timer" = 973134470;
          "iMovie" = 408981434;
        };
        onActivation = {
          cleanup = "zap";
          autoUpdate = true;
          upgrade = true;
        };
        taps = builtins.attrNames config.nix-homebrew.taps;
      }; 

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      programs.zsh = {
        enable = true;
        enableFzfHistory = true;
        enableSyntaxHighlighting = true;
      };

      system = {
        configurationRevision = self.rev or self.dirtyRev or null;
        checks.verifyNixPath = false;
        primaryUser = builtins.getEnv "USER";
        stateVersion = 6;

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

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Eriks-MacBook-Pro
    darwinConfigurations."M-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      modules = [ configuration
                  mac-app-util.darwinModules.default
                  nix-homebrew.darwinModules.nix-homebrew
                  {
                    nix-homebrew = {
                      # Install Homebrew under the default prefix
                      enable = true;

                      # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
                      enableRosetta = false;

                      # User owning the Homebrew prefix
                      user = config.system.primaryUser;

                      # Optional: Declarative tap management
                      taps = {
                        "homebrew/homebrew-core" = homebrew-core;
                        "homebrew/homebrew-cask" = homebrew-cask;
                      };

                      mutableTaps = false;
                      autoMigrate = true;
                    };
                  }
                ];
    };
  };
}
