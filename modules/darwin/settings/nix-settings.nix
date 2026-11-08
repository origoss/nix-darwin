{
  config,
  hostPlatform,
  pkgs,
  ...
}:
let
  home = config.users.users.${config.system.primaryUser}.home;
in
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

  # Determinate Nix reads nix.custom.conf; nix-darwin takes ownership of the
  # installer-written file. Hard-link identical files across store paths so
  # projects pinned to different nixpkgs revs share bytes on disk.
  environment.etc."nix/nix.custom.conf" = {
    knownSha256Hashes = [ "3bd68ef979a42070a44f8d82c205cfd8e8cca425d91253ec2c10a88179bb34aa" ];
    text = ''
      auto-optimise-store = true
    '';
  };

  # Generations are GC roots, so GC alone never frees them. Weekly: drop dev
  # shells not loaded in 30 days, then old generations (14d) and dead paths.
  launchd.daemons.nix-cleanup = {
    script = ''
      /usr/bin/find ${home}/code ${home}/teach ${home}/keynotes ${home}/ai \
        -maxdepth 5 -type d -name .direnv -mtime +30 -prune \
        -exec /bin/rm -rf {} +
      /nix/var/nix/profiles/default/bin/nix-collect-garbage --delete-older-than 14d
    '';
    serviceConfig = {
      StartCalendarInterval = [
        {
          Weekday = 0;
          Hour = 3;
          Minute = 0;
        }
      ];
      StandardOutPath = "/var/log/nix-cleanup.log";
      StandardErrorPath = "/var/log/nix-cleanup.log";
    };
  };
}
