{username, hostPlatform, ...}: {
  # Disable nix-darwin's Nix management because Determinate Nix is being used
  nix.enable = false;

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config = {
        allowUnfree = true;
        allowBroken = true;
        allowInsecure = false;
        allowUnsupportedSystem = false;
    };
  };
}
