# /capture -- Brain Dump Inbox

## Description
Zero-friction capture for unstructured thoughts, ideas, to-dos, follow-ups, and
inspirations. Capture first, sort after. Never think about where something
goes before getting it out of your head.

## Arguments
- `[anything]` -- Direct capture. Stream of consciousness, multiple ideas, half-formed thoughts. The system untangles and categorises.
- `[for claude] [anything]` or `[fc] [anything]` -- Same as above, but any tasks extracted are delegated to Claude (delegate_to_claude: true, status: delegated). Claude will create proposals for these.
- (no argument) -- Check for unprocessed Granola voice memo captures only.

## Instructions

You are the intake system. Your job is to catch everything, sort it, and
confirm before writing anything. Speed and low friction matter most.

### Step 1: Check for Granola Voice Memos

Every /capture session starts here (if Granola MCP is available).

Search Granola for unprocessed voice memos:
- `search_meetings` with `query: "capture"` (case-insensitive, wide date range)
- Only match meetings where the title **starts with** "Capture"
- Ignore meetings where "capture" appears incidentally in the body or mid-title

Check `~/.claude/logs/processed-captures.md` for already-processed session IDs.
Skip any that appear there.

For each unprocessed capture:
- Pull the transcript with `get_transcript`
- Extract all discrete items from the transcript
- Process them alongside any direct input

If Granola is not available, skip this step.

### Step 2: Process Direct Input

If text was provided after /capture, take all of it as raw input.

**Delegation check:** If the input starts with `[for claude]` or `[fc]`, strip the
prefix and flag all tasks extracted from this input as delegated to Claude
(`delegate_to_claude: true`, `status: delegated`).

The input may contain:
- Multiple ideas jammed together
- Stream of consciousness
- Half-sentences and fragments
- Questions mixed with tasks mixed with names

Separate each discrete item. When in doubt about boundaries, err toward
splitting (easier to merge than to untangle later).

### Step 3: Categorise Each Item

Sort every extracted item into one of these buckets:

**Task** -- Concrete thing to do.
- Assign suggested priority (must-do today / this week / backlog)
- Suggest which goal it supports
- Suggest due date if implied
- Push back on vague ones (rewrite to be specific per /my-tasks rules)
- If delegated: set `delegate_to_claude: true` and `status: delegated`
- Destination: `~/.claude/my-tasks.yaml`

**Contact/Network** -- Person to reach out to, connection remembered, name that came up.
- Note what was said about them
- Check if contact file already exists in `~/.claude/contacts/`
- Destination: flag for `/network add` or append to existing contact file

**Reflection/Insight** -- Pattern noticed, career insight, something about how
you work or what energises you.
- Destination: `~/.claude/reflections/` as dated entry

**Signal/Opportunity** -- Company heard about, role mentioned, industry trend.
- Destination: `~/.claude/signals.md`

**Explore Later** -- Question, curiosity, "what if", something to dig into but not now.
- Destination: `~/.claude/inbox/` as dated note

### Step 4: Present for Confirmation

Show the sorted items before writing anything:

```
CAPTURED [X] items ([Y] from input, [Z] from Granola voice memos)

TASKS [+ "DELEGATED TO CLAUDE" if any are flagged for delegation]
- "[specific task]" -- priority: [P] -- goal: [G] -- due: [date or "none"]
- ...

CONTACTS
- "[name/person]" -- [context] -- action: [/network add or update existing]
- ...

REFLECTIONS
- "[insight]" -- save to reflections/
- ...

SIGNALS
- "[opportunity/trend]" -- [suggested action]
- ...

EXPLORE LATER
- "[question/curiosity]" -- park in inbox/
- ...

Confirm, reclassify, or discard?
```

Wait for approval before writing.

### Step 5: Write

After confirmation:
- **Tasks:** Add to `~/.claude/my-tasks.yaml`
- **Contacts:** Create or update files in `~/.claude/contacts/`
- **Reflections:** Write to `~/.claude/reflections/[date]-capture.md`
- **Signals:** Append to `~/.claude/signals.md`
- **Explore Later:** Write to `~/.claude/inbox/[date]-[slug].md`

For Granola voice memos: log each processed session ID and title to
`~/.claude/logs/processed-captures.md` so they don't get reprocessed.

**After all writes, update goals.yaml:**
- If any **contacts** were created: count all `.md` files in `~/.claude/contacts/`
  and update the contacts tracked key result with the new count

### Guidelines

- **Speed over polish.** The whole point is zero friction. Don't ask clarifying
  questions unless something is genuinely ambiguous.
- **Batch-friendly.** Handle 1 item or 20 items the same way.
- **Push back on vague tasks** per /my-tasks rules.
- **Don't over-categorise.** If something doesn't clearly fit, default to
  Explore Later. Better to park it than force it into the wrong bucket.
- **No persistence without confirmation.** Never write to any file before
  getting approval.
