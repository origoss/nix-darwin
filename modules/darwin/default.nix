{
  username,
  ...
}: {
  imports = [
    ./settings
    ./services
    ./homebrew
  ];

  users.users."eja" = {
    name = "eja";
    home = "/Users/eja";
  };

  system.stateVersion = 6;

  programs.tmux = {
    enable = true;
    enableFzf = true;
    enableSensible = true;
    enableVim = true;
    extraConfig = ''
      set -g extended-keys on
      set -g extended-keys-format csi-u
    '';
  };
}
