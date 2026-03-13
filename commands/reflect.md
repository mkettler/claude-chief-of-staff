# /reflect -- Meeting Insights

## Description
Query meeting history to surface patterns about how you think, lead,
and decide. Feeds narrative building, interview prep, and self-awareness.

## Arguments
- (no argument) -- Guided exploration. Ask what to reflect on.
- `$PROMPT` -- Direct query against meeting history.

## Instructions

You are running a reflection session using available meeting history.
All data stays local.

### If no argument is provided

Present these options and ask which direction to explore:

1. **Leadership patterns** -- How do I run meetings, make decisions, give feedback?
2. **Impact stories** -- What decisions had the most impact? What did people praise?
3. **Energy map** -- What energises me vs. drains me based on meeting content?
4. **Narrative fuel** -- Surface stories and evidence for CV, interviews, outreach
5. **Relationship insights** -- Who do I collaborate with most? How do others see me?
6. **Custom query** -- Ask anything against the meeting history

### If a prompt is provided

Execute the query directly. If Granola MCP is available, use its tools to:

1. **Search broadly first** -- Use `search_meetings` with relevant keywords and a wide
   date range. Default to full archive. Only narrow the range if a specific period is requested.
2. **Pull transcripts for key meetings** -- Use `get_transcript` to read the actual
   conversations, not just summaries. The signal is in the words.
3. **Cross-reference patterns** -- Use `get_statistics` and `analyze_patterns` to
   quantify what you find.
4. **Synthesise, don't summarise** -- Draw conclusions. Connect dots. Surface
   something not already obvious.

If Granola is not available, offer to work with:
- Manual notes in `~/.claude/reflections/`
- Calendar history (if available)
- Any other data sources that are connected

### Output Format

```
REFLECT: [Topic]

WHAT I FOUND
[2-4 key findings, each with specific evidence from meetings]

PATTERNS
[Recurring themes across multiple meetings]

SO WHAT
[What this means for narrative building, interview prep, or self-awareness]

EVIDENCE
[Specific meeting references: title, date, relevant quotes or moments]
```

### Guidelines

- Always use a wide date range. The value is in patterns across months, not days.
- Quote actual words from transcripts when they're powerful. Real language > summary.
- Be honest about what you find. If the data shows avoidance or blind spots, say so.
- Connect findings back to goals. "This pattern matters because..."
- If data is thin on a topic, say so. Don't fabricate patterns from sparse data.
- This is private reflection. Be direct, not diplomatic.

### Persistence

After presenting findings, ask: "Worth saving this reflection?"

If yes, write the output to `~/.claude/reflections/[topic-slug]-[date].md`.
These files build a library of self-knowledge that can be referenced during
interview prep, narrative building, and future /reflect sessions.
