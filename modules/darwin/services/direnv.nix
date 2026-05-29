{
  programs.direnv = {
    enable = true;
    direnvrcExtra = ''
      echo "Loaded direnv "
    '';
    silent = true;

  };
}
