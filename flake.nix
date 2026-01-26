{
  description = "Erik nix-darwin system flake";
  
  nixConfig = {
    };
  
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
    homebrew-nikitabobko = {
      url = "github:nikitabobko/homebrew-tap";
      flake = false;
    };
    homebrew-fairwindsops = {
      url = "https://github.com/FairwindsOps/homebrew-tap";
      flake = false;
    };
    homebrew-helm = {
      url = "github:helm/chart-releaser";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, mac-app-util, nix-homebrew, homebrew-core, homebrew-cask, home-manager, homebrew-bundle, homebrew-nikitabobko, homebrew-helm, homebrew-fairwindsops,... }:
  let
    username = "eja";
    hostPlatform = "aarch64-darwin"; 
    hostname = "Eriks-MacBook-Pro-2";
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Eriks-MacBook-Pro-2
    darwinConfigurations."Eriks-MacBook-Pro-2" = nix-darwin.lib.darwinSystem {
      specialArgs = inputs;

      modules = [
        ./modules/darwin
        mac-app-util.darwinModules.default
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            # Install Homebrew under the default prefix
            enable = true;

            # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
            enableRosetta = false;

            # User owning the Homebrew prefix
            user = "eja";

            # Optional: Declarative tap management
            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
              "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
              "nikitabobko/homebrew-aerospace" = inputs.homebrew-nikitabobko;
              "FairwindsOps/homebrew-tap" = inputs.homebrew-fairwindsops;
              "helm/homebrew-chart-releaser" = inputs.homebrew-helm;
            };

            mutableTaps = false;
            autoMigrate = true;
          };
        }
	home-manager.darwinModules.home-manager  {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.verbose = true;
          home-manager.users.eja = import ./modules/home/home.nix; 
        }
      ];
    };
  };
}
