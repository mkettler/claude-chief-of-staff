# /signals -- Job Market & Industry Signals

## Description
Surface new professional opportunities, industry news, and relevant moves.
Not a daily command -- run on demand or weekly.

## Arguments
- (no argument) -- Full scan: job postings + company news + network moves
- `jobs` -- Job postings only
- `news` -- Industry news and company signals only
- `moves` -- Network moves only (check contacts for role changes)

## Instructions

You are scanning for professional signals relevant to the job search.
Use web search to gather current information.

**First:** Read `~/.claude/signals.md` for any signals captured via /capture since
the last run. Incorporate these into the relevant sections below.

### Step 1: Job Postings

Search for open roles matching target criteria from goals.yaml:
- Use target role titles and target markets
- Check career pages of priority companies
- Look for recently posted roles (last 7 days preferred, last 30 acceptable)

For each posting found:
- Title, company, location
- URL to the listing
- Why it's relevant (match to profile)
- Any network connections at that company (check contacts/)

### Step 2: Company News

Search for news about target companies and the broader industry:
- Leadership changes at target companies
- Funding rounds, product launches, expansions
- Industry trends in your field
- Target market news

For each signal:
- What happened
- Why it matters
- Suggested action (apply, reach out, note for later)

### Step 3: Network Moves

Read contact files in `~/.claude/contacts/` and check:
- Has anyone recently changed roles? (search web for their name + company)
- Are any contacts at companies that are hiring for target roles?

This step is lower fidelity since we can't scrape LinkedIn directly.

### Output Format

```
SIGNALS -- [Date]

NEW POSTINGS ([count] found)
1. [Title] at [Company] ([Location])
   URL: [link]
   Match: [why it fits]
   Network: [any contacts at this company, or "none"]

COMPANY SIGNALS
- [Company]: [what happened] -- [why it matters]

NETWORK MOVES
- [Name]: [what changed] -- [suggested action]

RECOMMENDED ACTIONS
1. [Most important thing to do based on above]
2. [Second priority]
3. [Third priority]
```

### Guidelines

- Quality over quantity. 3 strong matches beat 15 vague ones.
- Always check contacts/ for connections at companies with open roles.
- Be honest about match quality.
- Suggest concrete next steps, not "consider this."
- Suggest running once per week.

### Persistence

Write output to `~/.claude/logs/daily/[today's date].md` under a `## Signals` heading.
If strong postings found, suggest adding them as application tasks.
