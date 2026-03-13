# /network -- Network Pulse

## Description
Lightweight CRM for professional networking. Track contacts, surface stale
relationships, and keep outreach intentional and consistent.

## Arguments
- (no argument) -- Show network dashboard: active contacts, staleness alerts, suggested actions
- `add <name>` -- Create a new contact file from what you tell me + meeting history
- `<contact-name>` -- Show details and suggest next action for a specific contact

## Contact Files
Location: `~/.claude/contacts/`

## Instructions

### /network (dashboard)

Read all contact files in `~/.claude/contacts/` and present a pulse check.

```
NETWORK PULSE

NEEDS OUTREACH (overdue)
- [Name] ([category]) -- Last contact: [X days ago] via [channel]
  Relevance: [why they matter]
  Suggested action: "[specific, contextual suggestion]"

RECENTLY ACTIVE
- [Name] -- [last interaction summary] ([date])
  Next step: [what to do next]

PIPELINE
- Active opportunities: [contacts at target companies or with intros pending]
- Warm intros pending: [any introductions in progress]

STATS
- [X] contacts tracked | [Y] active | [Z] need attention
- Outreach this week: [count] (target: 3-5)
```

**Staleness thresholds:**
- Active contacts: flag if no interaction in 14+ days
- Warm contacts: flag if no interaction in 30+ days
- Dormant contacts: flag if no interaction in 60+ days

**Categories:**
- Active opportunities -- recruiters, hiring managers, people at target companies
- Warm network -- current and former colleagues, mentors
- Dormant but valuable -- haven't spoken in a while, should reconnect
- Industry contacts -- people met through communities, events, shared interests

### /network add <name>

1. Ask for context about the person (or use what's provided)
2. If Granola MCP is available, search meeting history using **both** approaches and deduplicate:
   a. `search_meetings` with `participant` filter (their email, wide date range)
   b. `search_meetings` with `query` filter (their name, or "Name / [Your Name]" pattern for 1:1 titles)
   Either approach alone will miss data. Always run both.
3. **Web augmentation for senior contacts** (Director level and above):
   - Run a web search for their name + company + LinkedIn/career
   - Build a career arc: previous companies, roles, industries, education
   - Add a `## Career Arc (Web Research)` section to the contact file
4. Create a contact file in `~/.claude/contacts/` using the template in `templates/contact.md`
5. Confirm creation and suggest a first outreach action.
6. **Update goals.yaml:** Count all `.md` files in `~/.claude/contacts/`. Update
   the contacts tracked key result with the new count. This is a self-correcting
   count, not an increment.

### /network <contact-name>

1. Find the contact file in `~/.claude/contacts/`
2. If Granola is available, check for any recent meetings with them
3. Present current status and suggest next action:

```
[NAME] -- [Category]
Last contact: [date] via [channel]
Relevance: [why they matter now]

Recent meeting activity: [any meetings found, or "none"]

Suggested next action: "[specific, send-ready suggestion]"
Want me to draft an outreach message?
```

### Guidelines

- Outreach suggestions must be genuine and specific. Never generic "just checking in" messages.
- Use meeting history to make outreach contextual -- reference something real from a past conversation.
- Track the Wednesday rule: if no outreach by Wednesday, flag it in the dashboard.
- When adding contacts, always search meeting history first. There's usually more shared history than you remember.
- Contact files are working documents. Update them every time there's a new interaction.
- Respect the 3-5 per week target. Don't suggest 10 outreach messages. Prioritise ruthlessly.
