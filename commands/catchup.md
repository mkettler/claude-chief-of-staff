# /catchup -- Cross-Session Context Rebuild

## Description
Rebuild context from what happened in other sessions. Run after compaction,
at the start of a new session, or anytime you need to catch up on changes
made elsewhere. This is about SESSION context, not daily state (that's /gm).

## Arguments
- (none) -- last 24 hours of session activity
- `today` -- only today's sessions
- `since YYYY-MM-DD` -- everything since the specified date

## Instructions

### Step 1: Read Session Summaries

Check `~/.claude/logs/sessions/` for summary files matching the time window.

- No argument: files modified within 24 hours
- `today`: files with today's date prefix
- `since [date]`: files dated >= specified date (warn if >7 days ago -- summaries auto-delete after 7 days)

Read each matching file. If none found, report "No session summaries found
for this period" and continue to Steps 3-5.

### Step 2: Read Today's Daily Log

Read `~/.claude/logs/daily/[today].md` if it exists. Extract:
- Morning Top 3 (what was planned)
- Midday check-in (if present)
- EOD results (if present)

If no daily log, note "No daily log for today yet."

### Step 3: Scan Task Changes

Read `~/.claude/my-tasks.yaml`. Identify:
- Tasks completed today or yesterday
- New tasks created (check created dates)
- Delegated tasks that moved status
- Tasks with notes referencing recent dates

### Step 4: Check Proposals

Read all YAML files in `~/.claude/proposals/`. Identify:
- Proposals created or decided in the time window
- Proposals with status: pending (awaiting review)
- Proposals with status: stuck

### Step 5: Recent Git Activity

Check recent commits in project repos and the CoS system repo.

### Output Format

```
CATCHUP -- [Date], [Time Window]

SESSIONS ([count] summaries)
[For each, chronologically:]
- [HH:MM] ([context]): [1-line of Done items]
  Handoffs: [items, or "none"]

DAILY LOG
- Morning briefing: [ran / not yet]
- Top 3: [list or "not set"]
- Midday check: [ran / not yet]

TASK CHANGES
- Completed: [task IDs + titles, or "none"]
- Created: [task IDs + titles, or "none"]
- Delegation moves: [proposal movements, or "none"]

PROPOSALS
- Awaiting review: [count + IDs]
- Stuck: [count + IDs]

COMMITS
[repo]: [count] -- [latest message]

HANDOFFS (action needed)
[Aggregated from all summaries, deduplicated:]
- [item] (from [HH:MM] session)
[Or "No open handoffs."]
```

### Guidelines

- This is NOT /gm. Don't check email, calendar, or pipeline.
- The HANDOFFS section is the most valuable part. Highlight it.
- If a handoff was resolved by a later session, mark it resolved.
- Speed matters. Under 2 minutes to read.

### Persistence

No output file. /catchup is a read operation.
