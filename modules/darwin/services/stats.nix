{
  # Stats is a menu-bar app (homebrew cask). Its built-in "Launch at login"
  # uses the SMAppService login-item DB, which rebuilds can't set declaratively.
  # A user launchd agent opens it at login instead. `open -a` attaches it to the
  # GUI session; no KeepAlive (open exits immediately and would relaunch-loop).
  launchd.user.agents.stats = {
    serviceConfig = {
      ProgramArguments = [
        "/usr/bin/open"
        "-a"
        "/Applications/Stats.app"
      ];
      RunAtLoad = true;
      StandardOutPath = "/tmp/stats.out.log";
      StandardErrorPath = "/tmp/stats.err.log";
    };
  };
}
