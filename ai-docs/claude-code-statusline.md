# Claude Code Status Line — Reference

Source: https://code.claude.com/docs/en/statusline (fetched 2026-05-29)

A status line is a bar at the bottom of Claude Code that runs a shell script you
configure. The script receives JSON session data on **stdin** and prints text to
**stdout**; Claude Code displays whatever it prints.

## Configure (settings.json)

`~/.claude/settings.json` (user) or project settings:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 2
  }
}
```

- `command` runs in a shell — can be a script path or an inline command.
- `padding` (optional, default 0): extra horizontal spacing in characters.
- `refreshInterval` (optional, min 1): re-run every N seconds on top of event
  updates. Use for clocks or when background subagents change git state while idle.
- `hideVimModeIndicator` (optional): suppress built-in `-- INSERT --` if your
  script renders `vim.mode` itself.

`/statusline <description>` makes Claude generate a script + wire settings for you.

## When it runs

After each new assistant message, after `/compact`, on permission-mode change, on
vim-mode toggle. **Debounced 300ms.** If a new update fires while the script is
still running, the in-flight run is **cancelled**. Edits to the script show on the
next interaction. Runs locally, **no API tokens**.

## Output rules

- **Multiple lines**: each `echo`/`print` = a separate row.
- **Colors**: ANSI escapes (`\033[32m` green, `\033[33m` yellow, `\033[31m` red,
  `\033[36m` cyan, `\033[0m` reset). Use `printf '%b'` over `echo -e` for reliability.
- **Links**: OSC 8 sequences (`\e]8;;URL\a TEXT \e]8;;\a`) — needs iTerm2/Kitty/WezTerm.
- **Terminal size**: read `COLUMNS`/`LINES` env vars (set by Claude Code v2.1.153+);
  `tput cols` won't work (output is captured, not a tty).

## stdin JSON schema

```json
{
  "cwd": "/current/working/directory",
  "session_id": "abc123...",
  "session_name": "my-session",
  "transcript_path": "/path/to/transcript.jsonl",
  "model": { "id": "claude-opus-4-8", "display_name": "Opus" },
  "workspace": {
    "current_dir": "/current/working/directory",
    "project_dir": "/original/project/directory",
    "added_dirs": [],
    "git_worktree": "feature-xyz",
    "repo": { "host": "github.com", "owner": "anthropics", "name": "claude-code" }
  },
  "version": "2.1.90",
  "output_style": { "name": "default" },
  "cost": {
    "total_cost_usd": 0.01234,
    "total_duration_ms": 45000,
    "total_api_duration_ms": 2300,
    "total_lines_added": 156,
    "total_lines_removed": 23
  },
  "context_window": {
    "total_input_tokens": 15500,
    "total_output_tokens": 1200,
    "context_window_size": 200000,
    "used_percentage": 8,
    "remaining_percentage": 92,
    "current_usage": {
      "input_tokens": 8500, "output_tokens": 1200,
      "cache_creation_input_tokens": 5000, "cache_read_input_tokens": 2000
    }
  },
  "exceeds_200k_tokens": false,
  "effort": { "level": "high" },
  "thinking": { "enabled": true },
  "rate_limits": {
    "five_hour": { "used_percentage": 23.5, "resets_at": 1738425600 },
    "seven_day": { "used_percentage": 41.2, "resets_at": 1738857600 }
  },
  "vim": { "mode": "NORMAL" },
  "agent": { "name": "security-reviewer" },
  "pr": { "number": 1234, "url": "https://...", "review_state": "pending" },
  "worktree": { "name": "...", "path": "...", "branch": "...", "original_cwd": "...", "original_branch": "main" }
}
```

### Field notes
- `context_window.used_percentage` — pre-calculated, input-only (input + cache
  create + cache read; excludes output). Simplest accurate context gauge. May be
  `null` early in the session → use a fallback.
- `context_window.context_window_size` — 200000 default, 1000000 for extended.
- `cost.total_cost_usd` — client-side estimate; may differ from bill.
- `effort.level` — low/medium/high/xhigh/max/ultra (ultra = ultracode).
- **Often absent**: `session_name`, `workspace.repo`, `effort`, `vim`, `agent`,
  `pr`, `worktree`, `rate_limits` (Pro/Max only, after first response).
- **Often null**: `context_window.current_usage` (null before first call + after
  `/compact`), `used_percentage`/`remaining_percentage` early on.

## Performance — caching slow ops (important)

The script runs frequently. `git status`/`git diff` can lag in big repos. Cache to
a temp file keyed by **`session_id`** (stable per session, unique across sessions —
do NOT use `$$`/pid, which changes every invocation):

```bash
CACHE_FILE="/tmp/statusline-git-cache-$SESSION_ID"
CACHE_MAX_AGE=5  # seconds
cache_is_stale() {
    [ ! -f "$CACHE_FILE" ] || \
    [ $(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0))) -gt $CACHE_MAX_AGE ]
}
if cache_is_stale; then
    # ... run git, write "$BRANCH|$STAGED|$MODIFIED" > "$CACHE_FILE"
fi
IFS='|' read -r BRANCH STAGED MODIFIED < "$CACHE_FILE"
```

## Tips & gotchas
- Test with mock input:
  `echo '{"model":{"display_name":"Opus"},"workspace":{"current_dir":"/x/project"},"context_window":{"used_percentage":25},"session_id":"test"}' | ./statusline.sh`
- Keep output short (limited width; long output truncates/wraps).
- Non-zero exit or no output → status line goes blank.
- Slow script blocks updates → stale output. Keep it fast.
- `disableAllHooks: true` also disables the status line.
- Requires workspace trust accepted (same gate as hooks).
- `claude --debug` logs exit code + stderr of the first invocation.
- Community: `ccstatusline` (sirmalloc), `starship-claude` (martinemde).
```
