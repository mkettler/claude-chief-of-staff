# /triage -- Comms Triage

## Description
Scan all connected communication channels, prioritise by urgency,
and draft responses in your voice. Clear the inbox in minutes, not hours.

## Arguments
- `quick` -- Tier 1 items only, no drafts (fastest)
- `digest` -- Full scan with summaries, drafts for Tier 1-2
- (no argument) -- Full scan with drafts for everything actionable

## Instructions

You are running inbox triage. The goal is to process all incoming
messages quickly and surface what needs attention. Max 30 minutes. If it's
going longer, stop and focus on Tier 1 only.

### Step 1: Scan Channels

Scan each connected channel. Only scan channels with active MCP servers.
Skip silently if a channel isn't connected.

**Channels (in priority order):**

1. **Email** -- Use whichever email MCP tools are available.
   - Focus on: responses to your outreach, time-sensitive requests, important personal
2. **Chat** -- If connected (Slack, Google Chat, etc.)
   - Focus on: Direct messages requiring response. Don't get pulled into channel noise.
3. **Other channels** -- As configured

### Step 2: Classify Each Item

Assign a triage tier:

| Tier | Criteria | Action |
|------|----------|--------|
| **1 -- Act Now** | Time-sensitive responses, important requests, warm intros | Draft response immediately |
| **2 -- Today** | Professional replies, follow-ups, important personal | Queue with draft |
| **3 -- Archive** | Newsletters, notifications, FYI-only, low-signal | Mark as read / archive |

### Step 3: Check for Already-Replied

Before drafting, verify you haven't already responded:
- Check sent mail for responses in the same thread
- If already handled, skip entirely

### Step 4: Draft Responses

For Tier 1 and Tier 2, draft send-ready responses that match your voice
(read my-profile.md for voice preferences).

For `quick` mode: Skip drafts, just list Tier 1 items.
For `digest` mode: Drafts for Tier 1, summaries for Tier 2.

### Step 5: Present Results

```
TRIAGE -- [Day], [Date] [Time]
Scanned: [channels] ([item counts])

TIER 1 -- Act Now
1. [Sender] -- [Subject/summary] ([channel], [wait time])
   Draft: "[proposed response]"

TIER 2 -- Today
2. [Sender] -- [Subject/summary] ([channel])
   Draft: "[proposed response]"

TIER 3 -- Archive
3-N. [Brief list]

SUMMARY: [X] items need action, [Y] drafts ready.
```

### Step 6: Await Approval

**NEVER send any message without explicit approval.**

After presenting drafts, wait for approval:
- Approve individual drafts ("send 1" or "y on 1")
- Approve all ("send all")
- Edit a draft ("change 2 to...")
- Skip items

### Guidelines

- Speed matters. Triage should take 2-3 minutes, not 10.
- Don't over-explain. You know your contacts.
- If nothing urgent, say so clearly: "Inbox clear. No items need immediate attention."
- For long email threads, summarise the thread, don't just quote the last message.
- This is not the time for deep work. Process and move on.
- If triage is taking more than 30 minutes, you've gone too deep. Stop and refocus.

### Persistence

After triage is complete, append a summary to `~/.claude/logs/daily/[today's date].md`
under a `## Triage` heading.
