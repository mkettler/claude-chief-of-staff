# /jobscan -- Job Pipeline Intelligence

## Description
Active intelligence scan for tracked job opportunities, market signals, and
radar expansion. Runs as part of /gm and on demand. Uses live web search.

## Arguments
- (no argument) -- Full scan: company intel + market signals + radar expansion
- `companies` -- Company intelligence only
- `market` -- Market signals only
- `radar` -- Radar expansion only

## Instructions

You are running a focused intelligence scan for the job search pipeline.
Use web search for all sections. Quality over quantity.

### Step 0: Load Pipeline

Read `~/.claude/jobs.md`. Identify:
- All entries with status "considering" or "active" (these are the focus)
- Patterns across entries: company types, industries, geographies, role shapes

If jobs.md is empty or has no active/considering entries, skip Step 1 and note
"No tracked companies to scan. Add roles with /job first."

### Step 1: Company Intelligence

For each company with status "considering" or "active":

Search for: "[company name] news [current month] [current year]"
Also search: "[company name] layoffs OR hiring OR leadership OR funding"

Surface (if found):
- Recent leadership changes (especially in target function areas)
- Layoffs, hiring freezes, or expansion announcements
- Product launches or strategic pivots
- Funding rounds or earnings that signal growth or contraction

For each finding, add a one-line recommendation:
- "Strengthens the case" -- positive signal
- "Worth monitoring" -- neutral but notable
- "Red flag" -- reconsider priority

### Step 2: Market Signals

Search across target sectors and geographies from goals.yaml:
- "[target role] hiring [target location] [current year]"
- "design leadership hiring trends [current year]" (adapt to your field)

Surface 3-5 signals maximum. Only include things that would change behaviour.

### Step 3: Radar Expansion

Based on patterns in jobs.md, search for companies not yet tracked that
might be worth knowing about:
- Adjacent companies in the same space
- Companies recently expanding in target locations
- Companies known for strong culture in your field

Present as a shortlist of 3-5 companies max. Don't pad this list.

### Output Format

```
JOBSCAN -- [Date]

COMPANY INTEL ([count] companies scanned)
[Company 1]: [finding] -- [recommendation]
[Company 2]: [finding] -- [recommendation]

MARKET SIGNALS
- [signal 1]
- [signal 2]

RADAR
- [Company]: [one-line reason]
```

### Guidelines

- Be brief. Scannable in under 2 minutes.
- Don't repeat information already in jobs.md. Only surface what's new.
- If a scan turns up something that should change a job's status, recommend it.
- Web search results are incomplete. Flag gaps.
- When running as part of /gm, keep output especially tight.

### Persistence

When run standalone, write output to `~/.claude/logs/daily/[today's date].md`
under a `## Jobscan` heading.
