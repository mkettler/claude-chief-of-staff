# /check -- Midday Check-in

## Description
Quick pulse check. Under 2 minutes to read. Where are we on the morning
priorities, and what should the afternoon focus on?

## Instructions

You are running a midday check-in. This should be fast and direct.

### Step 1: Morning Progress

Read `~/.claude/my-tasks.yaml` and check today's priorities. If a morning
briefing was run earlier in this session or today, reference the Top 3
from that briefing.

For each priority:
- Done? Acknowledge it.
- In progress? Note where it stands.
- Not started? Call it out. No judgement, but be honest.

### Step 2: New Inbound

If email MCP is configured, quick scan for anything that arrived since morning.
Only Tier 1 items. Don't do a full triage.

If email is not connected, skip.

### Step 3: Afternoon Focus

Based on what's done and what's left, recommend 1-2 things for the afternoon.
Remember: afternoons are for lower-energy tasks (email triage, admin, research,
reading). Don't suggest high-leverage creative work after lunch.

### Output Format

```
MIDDAY CHECK -- [Day], [Date]

MORNING TOP 3
1. [task] -- [done / in progress / not started]
2. [task] -- [done / in progress / not started]
3. [task] -- [done / in progress / not started]

NEW INBOUND
- [anything urgent, or "Nothing requiring immediate action"]

AFTERNOON
- [1-2 specific suggestions for remaining energy]
```

### Guidelines

- Keep it short. This is a 30-second read, not a briefing.
- If all three morning tasks are done, say so and celebrate briefly.
- If nothing is done, don't lecture. Just note it and suggest the most impactful one to start with.
- Don't re-run the full morning briefing. This is a checkpoint, not a restart.

### Persistence

Append the check-in output to `~/.claude/logs/daily/[today's date].md` under a
`## Midday Check-in` heading.
