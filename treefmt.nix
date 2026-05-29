{
  projectRootFile = "flake.nix";
  programs = {
    nixfmt.enable = true; # format
    deadnix.enable = true; # remove unused bindings
    statix.enable = true; # lint anti-patterns
  };
}
