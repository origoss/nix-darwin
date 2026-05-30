#!/bin/bash
# Lightweight Claude Code status line (bash + jq).
# Line 1: [Model] 📁 dir | 🌿 branch +staged ~modified
# Line 2: <context bar> pct% | $cost | ⏱ Mm Ss
# Git state is cached per session_id (5s) so this stays fast.

input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // "?"')
DIR=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
SESSION_ID=$(echo "$input" | jq -r '.session_id // "nosess"')
# Subscription rate-limit window (Claude.ai Pro/Max; absent otherwise)
RL5_PCT=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
RL5_RESET=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
RL7_PCT=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; RESET='\033[0m'
BYELLOW='\033[1;33m'; BRED='\033[1;31m'

# --- git, cached per session ---
CACHE_FILE="/tmp/statusline-git-cache-$SESSION_ID"
CACHE_MAX_AGE=5
cache_is_stale() {
    [ ! -f "$CACHE_FILE" ] || \
    [ $(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0))) -gt $CACHE_MAX_AGE ]
}
if cache_is_stale; then
    if git rev-parse --git-dir >/dev/null 2>&1; then
        B=$(git branch --show-current 2>/dev/null)
        S=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
        M=$(git diff --numstat 2>/dev/null | wc -l | tr -d ' ')
        echo "$B|$S|$M" > "$CACHE_FILE"
    else
        echo "||" > "$CACHE_FILE"
    fi
fi
IFS='|' read -r BRANCH STAGED MODIFIED < "$CACHE_FILE"

GIT=""
if [ -n "$BRANCH" ]; then
    GIT=" | 🌿 $BRANCH"
    [ "$STAGED" -gt 0 ] 2>/dev/null && GIT="$GIT ${GREEN}+${STAGED}${RESET}"
    [ "$MODIFIED" -gt 0 ] 2>/dev/null && GIT="$GIT ${YELLOW}~${MODIFIED}${RESET}"
fi

# --- context bar (color by usage) ---
if   [ "$PCT" -ge 32 ]; then BAR_COLOR="$BRED"
elif [ "$PCT" -ge 20 ]; then BAR_COLOR="$BYELLOW"
else BAR_COLOR="$GREEN"; fi
FILLED=$((PCT / 10)); EMPTY=$((10 - FILLED))
printf -v FILL "%${FILLED}s"; printf -v PAD "%${EMPTY}s"
BAR="${FILL// /█}${PAD// /░}"

# --- cost + duration ---
COST_FMT=$(printf '$%.2f' "$COST")
MINS=$((DURATION_MS / 60000)); SECS=$(((DURATION_MS % 60000) / 1000))

printf '%b\n' "${CYAN}[$MODEL]${RESET} 📁 ${DIR##*/}${GIT}"
printf '%b\n' "${BAR_COLOR}${BAR} ${PCT}%${RESET} | ${YELLOW}${COST_FMT}${RESET} | ⏱️ ${MINS}m ${SECS}s"

# --- subscription window: % used + time until reset (only if present) ---
if [ -n "$RL5_PCT" ]; then
    P5=$(printf '%.0f' "$RL5_PCT")
    if   [ "$P5" -ge 90 ]; then RL5_COLOR="$BRED"
    elif [ "$P5" -ge 80 ]; then RL5_COLOR="$BYELLOW"
    elif [ "$P5" -ge 60 ]; then RL5_COLOR="$YELLOW"
    else RL5_COLOR="$GREEN"; fi
    LINE="5h: ${RL5_COLOR}${P5}%${RESET} used"
    if [ -n "$RL5_RESET" ]; then
        SECS_LEFT=$((RL5_RESET - $(date +%s)))
        [ "$SECS_LEFT" -lt 0 ] && SECS_LEFT=0
        LINE="$LINE → resets in $((SECS_LEFT / 3600))h $(((SECS_LEFT % 3600) / 60))m"
    fi
    if [ -n "$RL7_PCT" ]; then
        P7=$(printf '%.0f' "$RL7_PCT")
        if   [ "$P7" -ge 95 ]; then RL7_COLOR="$BRED"
        elif [ "$P7" -ge 70 ]; then RL7_COLOR="$BYELLOW"
        elif [ "$P7" -ge 50 ]; then RL7_COLOR="$YELLOW"
        else RL7_COLOR="$GREEN"; fi
        LINE="$LINE | 7d: ${RL7_COLOR}${P7}%${RESET} used"
    fi
    printf '%b\n' "$LINE"
fi
