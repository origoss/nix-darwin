{pkgs, ...}: {
  environment = {
    shells = with pkgs; [bash zsh];
    systemPackages = with pkgs; [] ++ (import ./packages.nix { inherit pkgs; });
    systemPath = ["/usr/local/bin"];
    pathsToLink = ["/Applications" "/share/zsh"];
    variables = {
      EDITOR = "vim";
      PAGER = "less -R";
    };
  };
}