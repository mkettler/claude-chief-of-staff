#!/bin/bash
# Stop hook: context warning + stale MCP process cleanup
# Runs after every Claude response

INPUT=$(cat)
USED=$(echo "$INPUT" | jq -r '.context_window.used_percentage // 0')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')

# --- Context warning (once per session at 80%) ---
FLAG_FILE="/tmp/claude-context-warned-${SESSION_ID}"
if [ "$USED" -ge 80 ] && [ ! -f "$FLAG_FILE" ]; then
  touch "$FLAG_FILE"
  echo "CONTEXT WARNING: ${USED}% used (<20% remaining). Run /precompact NOW to save session knowledge before compaction. Do not continue working without saving durable learnings to MEMORY.md and daily log." >&2
  exit 2
fi

# --- Kill stale workspace-mcp processes (check every 30 min) ---
CLEANUP_FLAG="/tmp/claude-mcp-cleanup-${SESSION_ID}"
NOW=$(date +%s)
if [ -f "$CLEANUP_FLAG" ]; then
  LAST=$(cat "$CLEANUP_FLAG")
  ELAPSED=$((NOW - LAST))
  [ "$ELAPSED" -lt 1800 ] && exit 0
fi
echo "$NOW" > "$CLEANUP_FLAG"

# Kill workspace-mcp processes older than 2 hours (7200 seconds)
pgrep -f workspace-mcp | while read -r pid; do
  STARTED=$(ps -o lstart= -p "$pid" 2>/dev/null) || continue
  STARTED_TS=$(date -j -f "%a %b %d %T %Y" "$STARTED" +%s 2>/dev/null) || continue
  AGE=$((NOW - STARTED_TS))
  if [ "$AGE" -gt 7200 ]; then
    kill "$pid" 2>/dev/null
  fi
done

exit 0
