{
  ...
}:
{
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
}
