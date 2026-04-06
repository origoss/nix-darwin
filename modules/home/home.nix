{ config, pkgs, lib, mac-app-util, ... }:
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "eja";
  home.homeDirectory = "/Users/eja";
  home.packages = with pkgs; [];
  home.sessionVariables = {
    # EDITOR is set conditionally in zsh.initExtra based on SSH connection
   };

  # Integrate with macOS applications
  home.activation.trampolineApps = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ${mac-app-util.packages.${pkgs.system}.default}/bin/mac-app-util sync-trampolines
  '';
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

  xdg.configFile."aerospace/aerospace.toml".text = ''
    after-login-command = []
    after-startup-command = []
    start-at-login = true

    [gaps]
    inner.horizontal = 8
    inner.vertical   = 8
    outer.left       = 8
    outer.bottom     = 8
    outer.top        = 8
    outer.right      = 8

    [mode.main.binding]
    # Layout
    alt-slash = 'layout tiles horizontal vertical'
    alt-comma = 'layout accordion horizontal vertical'

    # Focus
    alt-h = 'focus left'
    alt-j = 'focus down'
    alt-k = 'focus up'
    alt-l = 'focus right'

    # Move
    alt-shift-h = 'move left'
    alt-shift-j = 'move down'
    alt-shift-k = 'move up'
    alt-shift-l = 'move right'

    # Resize
    alt-shift-minus = 'resize smart -50'
    alt-shift-equal = 'resize smart +50'

    # Workspaces
    alt-1 = 'workspace 1'
    alt-2 = 'workspace 2'
    alt-3 = 'workspace 3'
    alt-4 = 'workspace 4'
    alt-5 = 'workspace 5'
    alt-6 = 'workspace 6'
    alt-7 = 'workspace 7'
    alt-8 = 'workspace 8'
    alt-9 = 'workspace 9'

    # Move window to workspace
    alt-shift-1 = 'move-node-to-workspace 1'
    alt-shift-2 = 'move-node-to-workspace 2'
    alt-shift-3 = 'move-node-to-workspace 3'
    alt-shift-4 = 'move-node-to-workspace 4'
    alt-shift-5 = 'move-node-to-workspace 5'
    alt-shift-6 = 'move-node-to-workspace 6'
    alt-shift-7 = 'move-node-to-workspace 7'
    alt-shift-8 = 'move-node-to-workspace 8'
    alt-shift-9 = 'move-node-to-workspace 9'

    # Fullscreen
    alt-f = 'fullscreen'

    # Float / tile toggle
    alt-shift-space = 'layout floating tiling'

    # Reload config
    alt-shift-semicolon = 'reload-config'

    # Close window
    alt-shift-q = 'close'
  '';

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
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
    initExtra = ''
      fastfetch

      export XDG_CONFIG_HOME=''${XDG_CONFIG_HOME:-$HOME/.config}
      export XDG_CACHE_HOME=''${XDG_CACHE_HOME:-$HOME/.cache}
      export XDG_DATA_HOME=''${XDG_DATA_HOME:-$HOME/.local/share}
      export XDG_STATE_HOME=''${XDG_STATE_HOME:-$HOME/.local/state}

      if [[ -n $SSH_CONNECTION ]]; then
        export EDITOR='vim'
      else
        export EDITOR='hx'
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
