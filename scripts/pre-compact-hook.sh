#!/bin/bash
# PreCompact hook: writes a snapshot marker before compaction happens
# This gives Claude a signal to save important context

INPUT=$(cat)
TIMESTAMP=$(date +%Y-%m-%d-%H%M%S)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
USED=$(echo "$INPUT" | jq -r '.context_window.used_percentage // 0')
SNAPSHOT_DIR="$HOME/.claude/logs/compaction"

mkdir -p "$SNAPSHOT_DIR"

cat > "${SNAPSHOT_DIR}/${TIMESTAMP}.md" << EOF
# Compaction Snapshot - ${TIMESTAMP}

- Session: ${SESSION_ID}
- Context used: ${USED}%
- Trigger: compaction about to happen

## Reminder
Check MEMORY.md for any session knowledge that needs saving.
Check daily log for today's progress capture.
EOF

echo "COMPACTION IMMINENT (${USED}% context used). Before continuing: 1) Check if MEMORY.md needs updating with session learnings. 2) Check today's daily log is current. 3) After compaction, re-read MEMORY.md and today's daily log to restore context. Snapshot saved to: ${SNAPSHOT_DIR}/${TIMESTAMP}.md" >&2
exit 2
