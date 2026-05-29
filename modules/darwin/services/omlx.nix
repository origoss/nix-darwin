{ pkgs, ... }:
let
  # Local MLX inference server (OpenAI-compatible on :8000). Binds 0.0.0.0 so
  # the OpenViking podman container can reach it via host.containers.internal.
  # Models are discovered from ~/.omlx/models subdirectories.
  start = pkgs.writeShellScript "omlx-start" ''
    exec /opt/homebrew/bin/omlx serve \
      --host 0.0.0.0 --port 8000 \
      --model-dir "$HOME/.omlx/models" \
      --log-level info
  '';
in
{
  launchd.user.agents.omlx = {
    serviceConfig = {
      ProgramArguments = [ "${start}" ];
      RunAtLoad = true;
      KeepAlive = true; # long-running server: restart if it exits
      StandardOutPath = "/tmp/omlx.out.log";
      StandardErrorPath = "/tmp/omlx.err.log";
      EnvironmentVariables = {
        PATH = "/opt/homebrew/bin:/usr/bin:/bin";
      };
    };
  };
}
