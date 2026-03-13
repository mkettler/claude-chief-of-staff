#!/bin/bash
# Task Executor
# Picks up delegated tasks and revised proposals, executes them via claude -p.
# Can run manually or via launchd/cron schedule.
#
# Usage:
#   ~/.claude/scripts/task-executor.sh              # Process all pending work
#   ~/.claude/scripts/task-executor.sh --dry-run    # Show what would be processed

set -euo pipefail

PROPOSALS_DIR="$HOME/.claude/proposals"
TASKS_FILE="$HOME/.claude/my-tasks.yaml"
LOGDIR="$HOME/.claude/logs/automated"
LOGFILE="$LOGDIR/task-executor.log"
TIMESTAMP=$(date -Iseconds)
DRY_RUN=false
CLAUDE_BIN="${CLAUDE_BIN:-$(which claude)}"
WORKING_DIR="${WORKING_DIR:-$HOME/Code}"

if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
fi

mkdir -p "$LOGDIR"

# Clear nesting guard
unset CLAUDECODE

log() {
  echo "[$TIMESTAMP] $1" >> "$LOGFILE"
  echo "$1"
}

log "Task executor starting (dry_run=$DRY_RUN)"

# Find revised proposals (status: pending, decision: revise)
REVISED=$(grep -l 'decision: revise' "$PROPOSALS_DIR"/*.yaml 2>/dev/null | while read f; do
  status=$(grep '^status:' "$f" | head -1 | awk '{print $2}')
  if [[ "$status" == "pending" ]]; then
    echo "$f"
  fi
done)

# Find delegated tasks without proposals (new delegations needing initial work)
DELEGATED_TASKS=$(python3 -c "
import yaml, os, glob

tasks_file = os.path.expanduser('~/.claude/my-tasks.yaml')
proposals_dir = os.path.expanduser('~/.claude/proposals')

with open(tasks_file) as f:
    data = yaml.safe_load(f)

# Get all task IDs that already have proposals
proposal_task_ids = set()
for pf in glob.glob(os.path.join(proposals_dir, '*.yaml')):
    with open(pf) as f2:
        p = yaml.safe_load(f2)
        if p and 'task_id' in p:
            proposal_task_ids.add(p['task_id'])

# Find delegated tasks without proposals
for task in data.get('tasks', []):
    if not task.get('delegate_to_claude'):
        continue
    if task.get('status') in ('complete', 'proposal_ready', 'proposal_pending'):
        continue
    task_id = task.get('id', '')
    if task_id and task_id not in proposal_task_ids:
        print(f\"{task_id}|{task.get('title', 'untitled')}\")
" 2>/dev/null || true)

# Count work items
if [[ -z "$REVISED" ]]; then REVISED_COUNT=0; else REVISED_COUNT=$(echo "$REVISED" | wc -l | tr -d ' '); fi
if [[ -z "$DELEGATED_TASKS" ]]; then DELEGATED_COUNT=0; else DELEGATED_COUNT=$(echo "$DELEGATED_TASKS" | wc -l | tr -d ' '); fi
TOTAL=$((REVISED_COUNT + DELEGATED_COUNT))

if [[ "$TOTAL" -eq 0 ]]; then
  log "Nothing to process. Queue is empty."
  exit 0
fi

log "Found $REVISED_COUNT revised proposals, $DELEGATED_COUNT new delegations"

if [[ "$DRY_RUN" == "true" ]]; then
  echo ""
  echo "Would process:"
  if [[ -n "$REVISED" ]]; then
    echo "  REVISIONS:"
    echo "$REVISED" | while read f; do
      pid=$(grep '^proposal_id:' "$f" | awk '{print $2}')
      title=$(grep '^task_title:' "$f" | sed 's/^task_title: //')
      echo "    - $pid: $title"
    done
  fi
  if [[ -n "$DELEGATED_TASKS" ]]; then
    echo "  NEW DELEGATIONS:"
    echo "$DELEGATED_TASKS" | while IFS='|' read id title; do
      echo "    - $id: $title"
    done
  fi
  exit 0
fi

# Process revised proposals
if [[ -n "$REVISED" ]]; then
  echo "$REVISED" | while read f; do
    pid=$(grep '^proposal_id:' "$f" | awk '{print $2}')
    task_id=$(grep '^task_id:' "$f" | awk '{print $2}')
    title=$(grep '^task_title:' "$f" | sed 's/^task_title: //')
    note=$(grep '^decision_note:' "$f" | sed 's/^decision_note: //')

    log "Processing revision: $pid ($title)"

    "$CLAUDE_BIN" -p \
      "You are picking up a revision request for proposal $pid (task: $task_id).

Title: $title

The user reviewed the previous proposal and requested changes:
$note

Read the full proposal at $f and the deliverable files referenced in it.
Address the revision feedback, update the deliverables, then update the proposal YAML:
- Update the summary to reflect the new work
- Set status to 'pending' and decision to null (so it goes back for review)
- Keep the same proposal_id and task_id

Be thorough. The user was specific about what they want changed." \
      --model opus \
      --no-session-persistence \
      --allowedTools 'Read(*),Edit(*),Write(*),Glob(*),Grep(*),WebSearch(*),WebFetch(*)' \
      -d "$WORKING_DIR" \
      2>&1 >> "$LOGFILE" || log "ERROR processing $pid"

    log "Completed: $pid"
  done
fi

# Process new delegated tasks
if [[ -n "$DELEGATED_TASKS" ]]; then
  echo "$DELEGATED_TASKS" | while IFS='|' read id title; do
    log "Processing new delegation: $id ($title)"

    "$CLAUDE_BIN" -p \
      "You are executing a delegated task from the Chief of Staff system.

Task ID: $id
Title: $title

Read the full task details from ~/.claude/my-tasks.yaml (find the task by id: \"$id\").

Execute the task fully. When done:
1. Create a proposal YAML file in ~/.claude/proposals/ documenting what you did
2. Update the task status in ~/.claude/my-tasks.yaml to 'proposal_pending'
3. The proposal should include: summary of work done, deliverables with file paths, and execution_path 'A'

Follow the proposal YAML schema used by existing proposals in ~/.claude/proposals/.
Use proposal_id format: prop-YYYYMMDD-NNN (check existing files to avoid collisions)." \
      --model opus \
      --no-session-persistence \
      --allowedTools 'Read(*),Edit(*),Write(*),Glob(*),Grep(*),WebSearch(*),WebFetch(*)' \
      -d "$WORKING_DIR" \
      2>&1 >> "$LOGFILE" || log "ERROR processing $id"

    log "Completed: $id"
  done
fi

log "Task executor finished. Processed $TOTAL items."
