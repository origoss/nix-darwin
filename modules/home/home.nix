{ config, pkgs, ... }:
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "eja";
  home.homeDirectory = "/Users/eja";
  home.packages = with pkgs; [];
  home.sessionVariables = {
    EDITOR = "vim";
   };
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
        "git"
        "fzf"
        "helm"
        "kind"
        "kubectl"
        "kubectx"
        "kube-ps1"
        "macos"
      ];
    };
    initContent = ''
      fastfetch

      export XDG_CONFIG_HOME=''${XDG_CONFIG_HOME:-$HOME/.config}
      export XDG_CACHE_HOME=''${XDG_CACHE_HOME:-$HOME/.cache}
      export XDG_DATA_HOME=''${XDG_DATA_HOME:-$HOME/.local/share}
      export XDG_STATE_HOME=''${XDG_STATE_HOME:-$HOME/.local/state}

      if [[ -n $SSH_CONNECTION ]]; then
        export EDITOR='vim'
      else
        export EDITOR='nvim'
      fi

      export ARCHFLAGS="-arch $(uname -m)"

      PROMPT='$(kube_ps1)'"$PROMPT"
      export PATH="''${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

      [ -f ~/.kubectl_aliases ] && source ~/.kubectl_aliases
      [ -f ~/.zsh_variables ] && source ~/.zsh_variables
      [ -f ~/.zsh_funcs ] && source ~/.zsh_funcs
      [ -f ~/.zsh_aliases ] && source ~/.zsh_aliases
    '';
  };
}
