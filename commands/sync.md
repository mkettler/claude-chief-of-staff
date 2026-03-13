# /sync -- System Coherence Check

## Description
Validate that files across the Chief of Staff system agree with each other.
Not a health check (do files exist?) but a coherence check (do files match?).
Run after any significant system changes, or weekly as part of /diagnostics.

## Arguments
- (no argument) -- Full coherence scan across all file pairs
- `quick` -- Counts and dates only (< 30 seconds)
- `fix` -- Full scan + auto-fix what's safe, flag what's not

## Instructions

You are running a coherence check across the Chief of Staff system. This
catches drift between files before it compounds into confusion.

### Determine Mode

Check the argument:
- No argument or `full`: Run all 5 layers, present full report
- `quick`: Run Layer 1 (counts) and Layer 2 (dates) only, use compact output
- `fix`: Run all 5 layers, then auto-fix safe items and present decisions for the rest

---

### Layer 1: Count Consistency

These are mechanical checks. Numbers must match.

**Contacts:**
1. Count .md files in `~/.claude/contacts/` (excluding any README.md or template files)
2. Read `~/.claude/goals.yaml` and find the key result with metric matching "Contacts tracked" -- note its `current` value
3. If these disagree, flag it with exact values and file locations

**Commands:**
1. Count .md files in `~/.claude/commands/`
2. Flag if count seems unexpected

---

### Layer 1.5: Proposal System Checks

**Proposal files:**
1. Read all `.yaml` files in `~/.claude/proposals/`
2. Count proposals by status: pending, approved, in_progress, stuck, completed, rejected, deferred
3. Flag stuck proposals prominently

**Proposal-task alignment:**
1. For each proposal file, verify the referenced `task_id` exists in my-tasks.yaml
2. Verify the task's `delegate_to_claude` is `true`
3. Verify task status matches proposal status

**Delegated tasks without proposals:**
1. Find ALL tasks with `delegate_to_claude: true` and status NOT `pending`
2. For each, check if a proposal file exists in `~/.claude/proposals/` with matching `task_id`
3. Flag missing proposals

---

### Layer 2: Date & Freshness Checks

**goals.yaml "Last updated" header:**
- Read the comment or header at the top of `~/.claude/goals.yaml`
- If more than 14 days old, flag it

**Stale "this week" / "week of" references:**
- Search goals.yaml for phrases like "Week of", "this week", "current week"
- If any reference a specific week that is not the current week, flag it

**Overdue tasks:**
- Read `~/.claude/my-tasks.yaml`, find all pending or in_progress tasks with due_date before today
- Group by how overdue: 1-3 days (amber), 4-7 days (red), 8+ days (critical)

**Contact staleness:**
- For each contact file, check the most recent entry in Interaction History
- Apply staleness thresholds by category

---

### Layer 3: Content Contradictions

Skip this layer for `quick` mode.

**CLAUDE.md vs goals.yaml:**
- Check if goal summaries in CLAUDE.md match what's in goals.yaml
- Check if references align

**File references vs reality:**
- For referenced files or directories, verify they exist using Glob
- Flag any dead references

---

### Layer 4: Convention Propagation

Skip this layer for `quick` mode.

**Goal alignment values:**
- Read the goal names from `~/.claude/goals.yaml`
- Check each task's `goal_alignment` field in my-tasks.yaml
- Flag any task whose goal_alignment doesn't match a real goal name

**Status values:**
- Verify all task statuses use valid values: pending, in_progress, blocked, complete, delegated, proposal_pending, proposal_ready
- Flag any non-standard values

---

### Layer 5: Structural Bloat Detection

Skip this layer for `quick` mode.

**CLAUDE.md size:**
- Count lines. If >800 lines, flag for review.

**Completed task accumulation:**
- If >30 completed tasks, suggest archiving old ones.

**Inbox accumulation:**
- Count .md files in `~/.claude/inbox/`
- If >10 items, flag for triage.

---

## Output Format

### /sync (full scan)

```
SYSTEM SYNC -- [Date]

COUNTS
- Contacts: [files] files, goals.yaml says [N] -- [MATCH / MISMATCH]
- Commands: [file count] files

PROPOSALS
- Stuck: [count]
- Pending review: [count]
- Delegated tasks without proposals: [count or "none"]

FRESHNESS
- goals.yaml: last updated [date] ([X days ago]) -- [OK / STALE]
- Overdue tasks: [count by severity, or "none"]
- Stale contacts: [list or "all current"]

CONTRADICTIONS
- [List or "No contradictions found"]

CONVENTIONS
- Goal alignment: [OK / mismatches found]
- Status values: [OK / invalid values found]

BLOAT
- CLAUDE.md: [X] lines -- [OK / review recommended]
- Completed tasks: [X] -- [OK / archive recommended]
- Inbox: [X] items -- [OK / triage recommended]

ACTIONS NEEDED
[Grouped by urgency]

Auto-fixable (will apply with /sync fix):
- [action]

Needs your decision:
- [action]
```

### /sync quick

```
QUICK SYNC -- [Date]

Contacts: [files] vs goals [N] -- [OK / DRIFT]
Commands: [files] files
goals.yaml age: [X days] -- [OK / STALE]
Overdue tasks: [count or "none"]
Proposals: [stuck count] stuck, [pending count] pending
Inbox: [X items]

[If all OK: "System coherent."]
[If issues: "[X] issues found. Run /sync for details."]
```

### /sync fix

Run the full scan, then auto-fix safe items:

**Auto-fixable (safe to change without asking):**
- Count mismatches where the primary source is clear
- "Last updated" date headers
- Stale "Week of X" references

**NOT auto-fixable (always ask):**
- Task status changes
- Contact category changes
- CLAUDE.md content changes

After all fixes, re-run the quick sync to confirm coherence.

---

## Guidelines

- Be precise about which file says what.
- Don't fix things silently. Even auto-fixes should be reported.
- The goal is confidence, not perfection.
- This command is the immune system. Catch problems early.
- Keep the output scannable.

## Persistence

Write the full sync report to `~/.claude/logs/sync-[date].md`.
