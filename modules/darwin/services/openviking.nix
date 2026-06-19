{ pkgs, ... }:
let
  podman = "/opt/homebrew/bin/podman";

  # Double-quoted osascript arg (inner quotes escaped for AppleScript) so the
  # whole thing can sit inside a single-quoted `trap '...'` without quote nesting.
  notify =
    msg:
    ''/usr/bin/osascript -e "display notification \"${msg}\" with title \"OpenViking\" sound name \"Basso\""'';

  start = pkgs.writeShellScript "openviking-start" ''
    set -euo pipefail

    trap '${notify "failed to start — see /tmp/openviking.err.log"}' ERR

    # Use a clean (empty) registry auth file so podman ignores the
    # Docker Desktop / gcloud credential helpers in ~/.docker/config.json
    # (those break pulls of the public ghcr.io image).
    authfile="$HOME/.config/openviking/auth.json"
    mkdir -p "$(dirname "$authfile")"
    printf '{"auths":{}}' > "$authfile"
    export REGISTRY_AUTH_FILE="$authfile"

    # Ensure the podman machine is running (VM state is imperative on macOS;
    # init once with `podman machine init`).
    if ! ${podman} machine inspect --format '{{.State}}' 2>/dev/null | grep -q running; then
      ${podman} machine start
    fi

    # Idempotent: --replace recreates the container on each login.
    ${podman} run -d --replace --name openviking \
      -p 1933:1933 \
      -v "$HOME/.openviking:/app/.openviking" \
      ghcr.io/volcengine/openviking:latest
  '';

  # Polls /health; on the up->down transition notifies and attempts a
  # restart (start is idempotent: ensures the machine is up and --replace
  # recreates the container). A machine bounce sends SIGTERM and neither
  # RunAtLoad nor the container restart policy bring it back, so the health
  # job is what self-heals. It retries start on EVERY failed check (start is
  # idempotent) so a failed/missed login start or a botched restart recovers
  # on the next tick. The flag only debounces the notification — alert once
  # per outage, not every interval.
  health = pkgs.writeShellScript "openviking-health" ''
    flag=/tmp/openviking.down
    if /usr/bin/curl -fsS --max-time 5 http://localhost:1933/health >/dev/null 2>&1; then
      if [ -f "$flag" ]; then
        rm -f "$flag"
        ${notify "recovered — healthy again"}
      fi
    else
      if [ ! -f "$flag" ]; then
        : > "$flag"
        ${notify "is DOWN — restarting"}
      fi
      ${start} || ${notify "restart failed — see /tmp/openviking.err.log"}
    fi
  '';
in
{
  launchd.user.agents.openviking = {
    serviceConfig = {
      ProgramArguments = [ "${start}" ];
      RunAtLoad = true;
      StandardOutPath = "/tmp/openviking.out.log";
      StandardErrorPath = "/tmp/openviking.err.log";
      EnvironmentVariables = {
        PATH = "/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      };
    };
  };

  launchd.user.agents.openviking-health = {
    serviceConfig = {
      ProgramArguments = [ "${health}" ];
      StartInterval = 300;
      StandardErrorPath = "/tmp/openviking.health.log";
    };
  };
}
