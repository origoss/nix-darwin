{
  config,
  pkgs,
  ...
}:
let
  # fuzzy session switcher for the M-s tmux binding; mirrors the helper that
  # nix-darwin's programs.tmux.enableFzf used to generate (no home-manager equiv).
  fzfTmuxSession = pkgs.writeShellScript "fzf-tmux-session" ''
    set -e
    session=$(tmux list-sessions -F '#{session_name}' | ${pkgs.fzf}/bin/fzf --query="$1" --exit-0)
    tmux switch-client -t "$session"
  '';
in
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "eja";
  home.homeDirectory = "/Users/eja";
  home.packages = with pkgs; [
    nodejs
    cmux
    herdr # terminal multiplexer for AI coding agents (panes/workspaces, socket API)
    just # command runner (justfile)
    uv # isolated Python tool installer; `uv tool install mlx-whisper` for local meeting transcription
    vscode # was the visual-studio-code cask; mac-app-util trampolines it into /Applications
    (callPackage ./pkgs/slack-cli.nix { })
    (callPackage ./pkgs/carbonyl.nix { }) # Chromium in the terminal; browser inside a herdr/tmux pane
  ];

  home.file.".npmrc".text = ''
    prefix=${config.home.homeDirectory}/.npm-global
  '';

  home.file.".claude/statusline.sh" = {
    source = ./statusline.sh;
    executable = true;
  };

  # sanitizing shim for local Claude Code (used by `ccl`): lifts Claude Code's
  # stray 'system'-role messages into top-level `system` so omlx 0.3.12 accepts them
  home.file.".omlx/claude-shim.py" = {
    source = ./claude-shim.py;
    executable = true;
  };

  home.sessionVariables = {
    # EDITOR is set conditionally in zsh.initExtra based on SSH connection
  };

  # App trampolines are handled by mac-app-util.darwinModules.default (flake.nix).

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
    # Config version for compatibility
    config-version = 2

    # Startup commands
    after-login-command = []
    after-startup-command = []
    start-at-login = true

    # Normalizations
    enable-normalization-flatten-containers = true
    enable-normalization-opposite-orientation-for-nested-containers = true

    # Gaps configuration
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

  # Zed: native GUI editor for what Helix cannot render (inline images, markdown
  # preview, file tree). vim_mode, not helix_mode: evil-helix already trained vim
  # keys, and Zed's helix_mode is documented as incomplete.
  programs.zed-editor = {
    enable = true;
    extensions = [ "nix" ];
    userSettings = {
      vim_mode = true;
      telemetry = {
        diagnostics = false;
        metrics = false;
      };
    };
  };

  # tmux: moved here from nix-darwin's system-level programs.tmux (was /etc/tmux.conf).
  # HM uses different option names; enableFzf/enableVim/enableSensible extras that have
  # no HM toggle are reproduced verbatim below so behavior is identical to the old setup.
  programs.tmux = {
    enable = true;
    keyMode = "vi"; # sets mode-keys + status-keys vi; status-keys overridden to emacs below
    terminal = "tmux-256color"; # better truecolor/italics + correct terminfo vs screen-256color
    historyLimit = 100000; # HM default 2000 is tiny; match common configs
    baseIndex = 1; # HM default is 0; darwin used 1
    escapeTime = 0; # HM default is 10; darwin/sensible used 0
    aggressiveResize = true; # HM default false would clobber the sensible plugin's "on"
    mouse = true; # wheel-scroll Claude Code's fullscreen TUI (drag-select still uses tmux buffer, not pbcopy)
    extraConfig = ''
      # keep emacs-style command-prompt editing (keyMode = "vi" would flip this to vi)
      set -g status-keys emacs
      set -g renumber-windows on

      # new windows and splits open in the current pane's working directory
      bind c new-window -c '#{pane_current_path}'
      bind C new-session
      bind S switch-client -l
      bind % split-window -v -c '#{pane_current_path}'
      bind '"' split-window -h -c '#{pane_current_path}'

      # vim-style pane navigation + splits
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      bind s split-window -v -c '#{pane_current_path}'
      bind v split-window -h -c '#{pane_current_path}'

      # vi copy-mode with macOS clipboard (pbcopy) on yank
      bind-key -T copy-mode-vi p send-keys -X copy-pipe-and-cancel "tmux paste-buffer"
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"

      # fzf: M-p fuzzy-select tokens into the pane, M-s fuzzy-switch session
      bind-key -n M-p run "tmux split-window -p 40 -c '#{pane_current_path}' 'tmux send-keys -t #{pane_id} \"$(${pkgs.fzf}/bin/fzf -m | paste -sd\\  -)\"'"
      bind-key -n M-s run "tmux split-window -p 40 'tmux send-keys -t #{pane_id} \"$(${fzfTmuxSession})\"'"

      # Claude Code: pass prefix-o through as C-o (expand details); dump scrollback to a pager
      bind o send-keys C-o
      bind e capture-pane -S -10000 \; save-buffer /tmp/tmux-scrollback.txt \; new-window 'less /tmp/tmux-scrollback.txt'

      # csi-u extended keys (modern terminals / Helix)
      set -g allow-passthrough on
      set -as terminal-features 'xterm*:extkeys'
      set -g extended-keys on
      set -g extended-keys-format csi-u
      set -g focus-events on
    '';
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      # transcribe meeting audio -> <name>.txt (mlx-whisper, Apple-silicon local). Usage: transcribe meeting.m4a
      transcribe = "mlx_whisper --model mlx-community/whisper-large-v3-turbo --output-format txt";
    };
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
        export EDITOR='zeditor --wait' # --wait blocks so git commit/rebase see the saved buffer
      fi

      export ARCHFLAGS="-arch $(uname -m)"

      PROMPT='$(kube_ps1)'"$PROMPT"
      export PATH="''${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
      export PATH="$HOME/.npm-global/bin:$PATH"
      export PATH="$HOME/.local/bin/omp:$PATH"
      export PATH="$HOME/.local/bin:$PATH" # uv tool bins (mlx_whisper)

      export CLAUDE_CODE_ENABLE_TELEMETRY=1
      export CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1                          # traces (beta)
      export OTEL_METRICS_EXPORTER=otlp
      export OTEL_LOGS_EXPORTER=otlp
      export OTEL_TRACES_EXPORTER=otlp
      export OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
      export OTEL_EXPORTER_OTLP_ENDPOINT=https://telemetry.oracle-apps.origoss.com
      export OTEL_LOG_USER_PROMPTS=0                                        # content off (hosted policy)
      export OTEL_LOG_TOOL_CONTENT=0                                        # content off (hosted policy)
      export OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE=cumulative   # recommended

      # local Claude Code via omlx (Gemma 4) — `ccl` = local model, `claude` = subscription
      # model_id = subdir name under ~/.omlx/models (omlx serve has no pull; models are placed there)
      # omlx serves on 8001; claude-shim on 8000 lifts Claude Code's stray 'system'-role
      # messages into top-level `system` (omlx 0.3.12 rejects them with 422). launch -> shim.
      export OMLX_MODEL="gemma-4-26b-a4b-it-4bit"
      ccl() {
        curl -s --max-time 1 localhost:8001/v1/models >/dev/null 2>&1 \
          || { omlx serve --port 8001 >~/.omlx.log 2>&1 & sleep 3; }
        curl -s --max-time 1 localhost:8000/v1/models >/dev/null 2>&1 \
          || { python3 ~/.omlx/claude-shim.py 8000 8001 >~/.omlx-shim.log 2>&1 & sleep 1; }
        omlx launch claude --model "$OMLX_MODEL" --port 8000 "$@"
      }

      [ -f ~/.kubectl_aliases ] && source ~/.kubectl_aliases
      [ -f ~/.zsh_variables ] && source ~/.zsh_variables
      [ -f ~/.zsh_funcs ] && source ~/.zsh_funcs
      [ -f ~/.zsh_aliases ] && source ~/.zsh_aliases
    '';
  };
}
