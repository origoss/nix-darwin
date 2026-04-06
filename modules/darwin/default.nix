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
  };
}
