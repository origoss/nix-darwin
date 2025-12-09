{
  username,
  ...
}: {
  imports = [
    ./settings
    ./services
    ./homebrew
  ];

  users.users."${username}" = {
    name = username;
    home = "/Users/${username}";
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
