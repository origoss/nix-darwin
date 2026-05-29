{ hostPlatform, ... }:
{
  # Disable nix-darwin's Nix management because Determinate Nix is being used
  nix.enable = false;

  nixpkgs = {
    inherit hostPlatform;
    config = {
      allowUnfree = true;
      allowInsecure = false;
      allowUnsupportedSystem = false;
    };
  };
}
