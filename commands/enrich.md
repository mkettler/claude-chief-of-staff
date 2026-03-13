# /enrich -- Contact Enrichment

## Description
Deep-enrich a specific contact using meeting history and available
channel data. Builds the context needed for genuine, informed outreach.

## Arguments
- `<contact-name>` -- Enrich a specific contact with meeting history and channel data
- `stale` -- Show contacts overdue for engagement based on category cadence

## Instructions

You are enriching contact profiles for professional networking.
The goal is to build rich context so outreach is genuine, specific, and
not transactional.

### /enrich <contact-name>

Deep enrichment of a specific contact.

1. **Find the contact file** in `~/.claude/contacts/`
   - If no file exists, offer to create one (use /network add template)

2. **Search meeting history** (if Granola MCP is available) using both approaches and deduplicate:
   - `search_meetings` with `participant` filter (their email, wide date range)
   - `search_meetings` with `query` filter (their name, or "Name / [Your Name]" title pattern)
   - Either approach alone misses data -- always run both
   - For each meeting found, pull the transcript with `get_transcript`
   - Look for: topics discussed, decisions made together, shared projects,
     how they interacted with you, any personal details mentioned

3. **Web augmentation for senior contacts** (Director level and above):
   - Run a web search for their name + company + LinkedIn/career
   - Build or update their career arc: previous companies, roles, industries
   - Update the `## Career Arc (Web Research)` section in the contact file

4. **Scan connected channels** (if MCP available):
   - Recent email exchanges
   - Calendar -- upcoming meetings with this person

5. **Update the contact file** with:
   - Enriched context from meeting history (specific quotes, shared history)
   - Updated interaction history
   - Refreshed talking points for next interaction
   - Any personal details learned (interests, family mentions, career moves)

6. **Present what was found:**
   ```
   ENRICHED: [Name]

   FROM MEETINGS ([X] meetings found)
   - [Key finding 1 -- specific shared context or discussion]
   - [Key finding 2]
   - [Notable quote or moment]

   UPDATED
   - Last interaction: [date] (was [previous date])
   - Added: [new context]
   - Talking points: [refreshed suggestions]

   UPCOMING
   - [Any scheduled meetings or pending follow-ups]

   OUTREACH ANGLE
   Based on your shared history, here's a genuine way to reconnect:
   "[Suggested opening that references something real]"

   Want me to draft a full outreach message?
   ```

### /enrich stale

Check which contacts are overdue for engagement.

1. Read all contact files in `~/.claude/contacts/`
2. Compare last interaction date against category cadence:
   - Active opportunities: flag if 14+ days
   - Warm network: flag if 30+ days
   - Dormant but valuable: flag if 60+ days

3. Present:
   ```
   RELATIONSHIP HEALTH

   NEEDS ATTENTION
   - [Name] ([category]) -- Last contact: [X days ago]
     Why they matter: [relevance]
     Suggested action: "[specific, contextual suggestion]"

   APPROACHING STALE
   - [Name] -- [days until threshold]

   HEALTHY
   - [X] contacts within cadence

   Want me to enrich any of these or draft outreach?
   ```

### Guidelines

- Meeting history is the secret weapon. Use it. Reference specific conversations,
  not generic "we worked together" statements.
- When updating talking points, make them specific: not "catch up" but
  "ask about the platform migration she mentioned in November."
- Don't over-enrich. Only add genuinely useful context, not filler.
- Respect privacy -- don't surface sensitive personal details from transcripts
  without good reason.
- Every enrichment should end with an actionable outreach angle.
- This pairs with /network: enrich builds depth, network manages breadth.
