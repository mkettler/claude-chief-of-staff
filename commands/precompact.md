Review this session before we compact. Follow these steps in order:

## Step 1: Check uncommitted work

Run `git status` in active project directories. Flag any uncommitted changes
that might be lost. Don't commit anything -- just report.

Also check `~/.claude/` repo for uncommitted changes.

## Step 1.5: Write Session Summary

Write a structured session summary to `~/.claude/logs/sessions/`.

1. Create the directory if needed: `mkdir -p ~/.claude/logs/sessions/`
2. Generate filename: `$(date +%Y-%m-%d-%H%M%S).md`
3. Scan the conversation for what happened this session
4. Write the summary using this format:

```
# Session Summary -- [YYYY-MM-DD HH:MM]

**Working directory:** [primary directory this session operated in]
**Context:** [interactive | automated-gm | automated-eod]

## Done
- [Specific accomplishment, one per line]

## Files Changed
- `/absolute/path/to/file` (created | modified | deleted)

## Tasks Updated
- task-XXX: [old status] -> [new status] ([title])

## Proposals
- prop-XXXXXXXX-XXX: [created | updated | decided] for task-XXX

## Decisions
- [Any convention, preference, or rule established]

## Handoffs
- [Anything incomplete that needs pickup by next session]
- [Blocked items with reason]

## Memory Updates
- [Changes made to MEMORY.md or topic files, or "None"]
```

**Rules:**
- Under 50 lines. Bullet points only, no prose.
- Absolute paths only, never relative.
- Handoffs is the most important section.
- If the session was trivial, write a minimal summary.
- Skip sections that have nothing to report (except Done and Handoffs).

## Step 2: Review session for durable learnings

Scan the conversation for:
- New decisions, conventions, or preferences established
- Files created or significantly modified
- Problems solved (and their solutions)
- Things that didn't work (so we don't repeat them)
- Contact interactions or pipeline updates
- Anything that should survive compaction

## Step 3: Check MEMORY.md line count

Read the project memory MEMORY.md. Count lines. If approaching 180 lines,
identify content that should move to topic files.

MEMORY.md must stay under 200 lines. Target 150 or fewer.

## Step 4: Cross-memory check

Find all MEMORY.md files across projects:
- Glob for `~/.claude/projects/*/memory/MEMORY.md`

Read each one. Flag any entries from this session that should propagate.
Propose cross-updates if needed.

## Step 5: Propose changes

Present a clear summary of what you plan to write to MEMORY.md and topic files.
Wait for confirmation before writing.

Only write things that are true and durable right now. Do not log failed attempts,
abandoned approaches, or anything tried and discarded.

## Step 6: Write and verify

After confirmation:
1. Write the approved changes
2. Verify MEMORY.md is under 200 lines
3. Update today's daily log if not already current

## Step 7: Git backup

Run in `~/.claude/`:
```
git add -A && git commit -m "precompact: session checkpoint $(date +%Y-%m-%d-%H%M)"
```
