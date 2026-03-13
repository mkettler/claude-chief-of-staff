# /eod -- Closing Ritual

## Description
End-of-day shutdown. Capture what happened, clear loose threads from your
head, and pre-load tomorrow. This is how evenings stay protected.

## Instructions

You are running the closing ritual. This is critical -- it's the boundary
between work and personal time. Make it complete so nothing lingers.

### Step 0: Read Today's Log

Check if `~/.claude/logs/daily/[today's date].md` exists. If it does, read it
to see what was planned this morning (Top 3, pipeline status) and any midday
check-in notes. Use this as the baseline for the Done/Not Done assessment.

### Step 1: Done Today

Read `~/.claude/my-tasks.yaml` and check the day's activity. Also reference
what happened in today's session(s) if available.

List what was actually accomplished. Include small wins. Acknowledging
progress matters, especially during transitions when wins feel scarce.

### Step 2: Not Done and Why

For anything that was planned but didn't happen, be honest about why:
- **Avoidance** -- was this something uncomfortable that got dodged?
- **Deprioritised** -- something more important came up, fair enough
- **Blocked** -- waiting on someone or something external
- **Ran out of time** -- calendar was fuller than expected
- **Energy** -- just didn't have it today, and that's real

Don't soften this. Honest accounting, not comfort.

### Step 3: Today's Meetings

If Granola MCP is available, use `list_meetings` to fetch today's meetings.
For each meeting with a summary or transcript:
- **Commitments made** -- anything promised to do or deliver
- **Follow-ups owed** -- people expecting a response, document, or action
- **Contacts worth tracking** -- anyone new or notable who should be added via /network

Cross-reference against `~/.claude/my-tasks.yaml`. If commitments aren't captured
as tasks yet, flag them and suggest adding them.

If Granola is not available, skip and ask: "Any meetings today with follow-ups I should capture?"

### Step 4: Loose Threads

Capture anything that needs action tomorrow morning, including uncaptured
items from Step 3. The point is to get things out of your head and into the
system so you can actually switch off.

For each thread:
- What it is
- What the next action is
- How urgent it is (first thing tomorrow vs. this week)

### Step 5: Tomorrow's Draft Top 3

Pre-load tomorrow's priorities based on:
- Anything carried over from today
- Calendar commitments tomorrow (check calendar MCP if available)
- Goal-aligned work that's been waiting
- Any deadlines approaching

These are drafts -- the morning briefing will finalise them.

### Step 6: Final Capture

Before shutting off, prompt: "Anything else floating around before you
switch off? Ideas, names, loose thoughts -- say it now and I'll sort it."

If input is provided, process it using /capture categorisation logic
(Task / Contact / Reflection / Signal / Explore Later), present for
confirmation, and write to the appropriate files.

If nothing, move on.

### Step 7: Memory Review

Review today's sessions and check if anything should be added to MEMORY.md
before signing off. Flag candidates and wait for confirmation before
writing anything.

### Step 7b: Project Git Health Check

Scan project repos for uncommitted changes. Run the git health check script.

For each repo with uncommitted work:
1. List modified and untracked files
2. Summarise what the changes are
3. Draft a commit message
4. Present: "[repo]: [count] uncommitted files. [summary].
   Suggested commit: '[message]'. Commit and push? (yes/skip)"

Wait for confirmation before committing each repo.

After project repos are handled, commit the CoS system:
```
git -C ~/.claude add -A && git -C ~/.claude commit -m "eod: session checkpoint $(date +%Y-%m-%d)"
```

### Step 7c: Quick Sync

Run /sync quick inline. If issues found, add them to LOOSE THREADS
for tomorrow's /gm to pick up. Don't fix them now -- it's end of day.

### Step 7d: Write Session Summary

Write a session summary to `~/.claude/logs/sessions/` using the same format
as /precompact Step 1.5.

1. Create the directory if needed: `mkdir -p ~/.claude/logs/sessions/`
2. Generate filename: `$(date +%Y-%m-%d-%H%M%S).md`

Also clean up old session summaries:
```
find ~/.claude/logs/sessions/ -name "*.md" -mtime +7 -delete
```

### Step 8: One Thing That Went Well

End on something real. Not forced positivity. One genuine thing -- a good
conversation, a task completed, a decision made, a moment of clarity.

### Output Format

```
END OF DAY -- [Day], [Date]

DONE TODAY
- [accomplishment]
- [accomplishment]

NOT DONE
- [task] -- [reason: avoidance / deprioritised / blocked / energy]

FROM TODAY'S MEETINGS
- [commitments/follow-ups not yet in tasks, or "All captured"]
- [new contacts worth adding to /network, or "None"]

LOOSE THREADS
- [thread] -- next action: [action] -- urgency: [tomorrow AM / this week]

TOMORROW'S TOP 3 (DRAFT)
1. [priority]
2. [priority]
3. [priority]

FINAL CAPTURE
Anything else floating around before you switch off?
[Process any input, or "Nothing -- clean shutdown."]

MEMORY REVIEW
[Candidates for MEMORY.md, or "Nothing new to capture."]

GIT HEALTH
[For each repo with uncommitted work:]
- [repo]: [count] files. [summary]. Commit and push? (yes/skip)
[Or "All repos clean."]

ONE GOOD THING
[Something real]
```

### Guidelines

- This should take < 3 minutes to read.
- Be direct about avoidance. "You skipped the outreach again" is more helpful than "outreach was deprioritised."
- The loose threads section is the most important part. If you go to bed thinking about work, this ritual failed.
- Tomorrow's Top 3 should be specific and actionable, not vague intentions.
- The "one good thing" should never feel like a participation trophy. If the day was rough, acknowledge that too.
- Hard stop. After this ritual, work is done. Don't get pulled back into tasks.

### Persistence

After presenting the ritual, append the full output to `~/.claude/logs/daily/[today's date].md`
under a `## End of Day` heading. This file is read by tomorrow's /gm to pick up
loose threads and draft Top 3.
