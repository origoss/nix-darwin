{username, hostPlatform, ...}: {
  nix.settings = {
    experimental-features = "nix-command flakes";
    extra-sandbox-paths = ["/tmp"]; # Extra paths to bind-mount in the sandbox
    trusted-users = [username]; # Users that have additional permissions
    auto-optimise-store = true;
  };

  nixpkgs = {
    hostPlatform = hostPlatform;
    config = {
        allowUnfree = true;
        allowBroken = true;
        allowInsecure = false;
        allowUnsupportedSystem = false;
    };
  };

  nix.enable = false;
}