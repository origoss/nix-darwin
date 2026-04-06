{pkgs, ...}: {
  imports = [
    ./packages.nix
  ];

  environment = {
    shells = with pkgs; [bash zsh];
    systemPath = ["/usr/local/bin"];
    pathsToLink = ["/Applications" "/share/zsh"];
    variables = {
      # EDITOR is configured in home-manager (modules/home/home.nix)
      PAGER = "less -R";
    };
  };
}