# /gm -- Morning Briefing

## Description
Start your day with a structured briefing. Know exactly what matters before
you open your inbox. Takes < 5 minutes to read.

## Instructions

You are running the morning briefing. Follow these steps in order,
collecting information before presenting the final briefing.

### Step 0: Read Yesterday's Log

Check if `~/.claude/logs/daily/[yesterday's date].md` exists. If it does,
read the LOOSE THREADS and TOMORROW'S TOP 3 sections. Use these to inform
today's Top 3 and to verify nothing was dropped overnight.

### Step 0b: Check Unprocessed Captures

Check for unprocessed Granola voice memos (if Granola MCP is available):
- `search_meetings` with `query: "capture"` (wide date range)
- Cross-reference against `~/.claude/logs/processed-captures.md`
- If unprocessed captures exist, surface them before the Top 3:
  "You have [X] unprocessed voice captures. Run /capture to sort them."

Also check `~/.claude/inbox/` for any explore-later items parked there.
If items exist, mention the count: "[X] items in your inbox from previous
captures. Review during weekly diagnostics or when you have a spare moment."

### Step 0c: Git Health Check

Run the git health check script `~/.claude/scripts/git-health-check.sh`
and parse its output.

The script checks repos for uncommitted changes and unpushed commits.
If the output shows all repos clean, skip this section. If any repo has
issues, surface them in the briefing under a GIT HEALTH section.

### Step 0d: Sync Check

If yesterday's /eod flagged sync issues (check today's log or yesterday's log
for QUICK SYNC output), surface them here:
"Sync issues from last night: [list]. Want me to fix now or after briefing?"

If no sync issues were flagged, skip silently.

### Step 1: Calendar Review

If calendar MCP is configured, fetch today's events.

For each event, note:
- Time and duration
- Title and attendees
- Whether it requires preparation
- Any conflicts or back-to-back meetings

Flag:
- Meetings that conflict with the morning focus block
- Back-to-back meetings with no buffer
- Anything after the hard stop time

If calendar MCP is not connected, skip and note it.

### Step 1b: Yesterday's Meetings

If Granola MCP is available, use `list_meetings` to fetch yesterday's meetings.
For each meeting with a summary or transcript:
- Check for action items, follow-ups, or commitments made
- Cross-reference against `~/.claude/my-tasks.yaml`
- Flag anything that fell through the cracks

If Granola is not available, skip this step.

### Step 2: Overnight Messages

If email MCP is configured, scan for anything requiring response.
Only surface Tier 1 items here. Don't do a full triage.

If email MCP is not connected, skip and note it.

### Step 3: Goal Pipeline

Read `~/.claude/goals.yaml` and present primary goal progress:
- Key results with current vs target
- Any follow-ups due
- Outreach or actions scheduled

If the job-search module is active (commands/modules/job-search/ exists),
also run /jobscan logic inline.

### Step 4: Top 3 for Today

Based on calendar, tasks, goals, and pipeline status, propose the three most
important things to move forward today. These must be:
- **Specific and actionable** -- not "work on project" but "Finish the API integration tests"
- **Aligned to goals** -- reference which goal each advances
- **Achievable today** -- given the calendar and energy available

Prioritise high-leverage work for the morning block.

### Step 5: Challenge

Call out one thing you're probably avoiding. This is not optional.

Look for:
- Outreach that's been meaning to happen but hasn't
- Tasks that keep getting carried over day after day
- Uncomfortable conversations postponed
- The thing that would have the most impact but feels hardest

Be direct. "You've been avoiding [X] for [Y days]. Today's the day."

### Output Format

```
Good morning. It's [Day], [Date].

CALENDAR ([count] events)
- [time]  [title] ([duration]) [flags if any]
- ...
[If applicable: "Heads up: [conflict or concern]"]

GIT HEALTH
- [repo]: [status -- clean / X modified, Y untracked / unpushed commits]
[If issues: "Want me to review and commit these?"]

YESTERDAY'S MEETINGS
- [Uncaptured action items, or "All follow-ups already tracked"]

OVERNIGHT
- [Tier 1 items or "Nothing urgent overnight"]

PIPELINE
[Goal progress, key results, follow-ups due]

TOP 3 FOR TODAY
1. [task] -- [goal it serves]
2. [task] -- [goal it serves]
3. [task] -- [goal it serves]

CHALLENGE
[The thing you're avoiding. Be specific.]
```

### Guidelines

- Be concise. The whole briefing should fit on one screen.
- Lead with the most important information.
- The Top 3 should be specific enough to start immediately without further planning.
- The Challenge must be genuine, not manufactured. If there's nothing being avoided, say "No obvious avoidance today. Keep that up."
- If today's calendar is misaligned with goals, say so explicitly.
- If no progress on the primary goal has happened this week and it's Wednesday or later, escalate the Challenge.
- Don't suggest admin or triage tasks for the morning block. Mornings are for high-leverage work.
- End with: "Want me to run /triage or prep for any of today's meetings?"

### Persistence

After presenting the briefing, write it to `~/.claude/logs/daily/[today's date].md`.
If the file already exists (e.g. from an earlier /check or /eod), prepend to it
under a `## Morning Briefing` heading. This log is read by /eod and tomorrow's /gm.
