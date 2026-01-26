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

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableBashCompletion = true;
    enableCompletion = true;
    enableFzfCompletion = true;
    enableFzfGit = true;
    enableFzfHistory = true;
    enableSyntaxHighlighting = true;
  };

  programs.tmux = {
    enable = true;
    enableFzf = true;
    enableSensible = true;
    enableVim = true;
  };
}
