# /setup -- Initial System Setup

## Description
Interactive setup wizard for the Chief of Staff system. Creates your personal
profile, initial goals, and task file. Run this once when you first clone the repo.

## Instructions

You are setting up the Chief of Staff system for a new user. This should feel
like a conversation, not a form. Keep it warm and efficient.

### Step 0: Check Location

Verify this repo is at `~/.claude/` (or symlinked there). Claude Code reads
CLAUDE.md from `~/.claude/CLAUDE.md`.

If not:
```
This repo needs to be at ~/.claude/ for Claude Code to use it.

Option A: Move it there
  mv [current-path] ~/.claude

Option B: Symlink it
  ln -s [current-path] ~/.claude

Which would you prefer?
```

Also check if `~/.claude/settings.json` exists (from this repo's `settings.json`).
If a settings.json already exists at `~/.claude/settings.json`, ask before overwriting.

### Step 1: Get to Know You

Ask these questions conversationally. Don't dump them all at once -- ask 2-3
at a time and build on the answers.

**Round 1: Who you are**
- What's your name?
- What do you do? (role, company, industry)
- What's your primary goal right now? (career move, shipping a product, learning something, building a business)

**Round 2: How you work**
- How would you describe your communication style? (direct/diplomatic, concise/detailed, formal/casual)
- When's your peak energy? (morning person, night owl, variable)
- Any hard boundaries on your time? (family time, no weekends, etc.)

**Round 3: What you need**
- What's the thing you most often procrastinate on?
- Any writing voice preferences? (British/American English, emoji use, formality level)
- What tools do you already have connected? (Gmail, Calendar, Granola, Slack)

### Step 2: Generate my-profile.md

Based on the answers, generate `~/.claude/my-profile.md` using a natural,
first-person format. Structure it like the example in `my-profile.md.example`
but with their actual information.

Present the draft and ask: "Does this capture you well? Anything to add or change?"

Iterate until they're happy, then write the file.

### Step 3: Generate goals.yaml

Based on the primary goal and conversation, generate `~/.claude/goals.yaml`:

1. Set the primary_goal based on what they said
2. Always include these supporting goals (adapt wording to their context):
   - Network/relationships (everyone benefits from this)
   - Daily structure (the system depends on this)
   - Comms management (everyone has inbox problems)
3. Add 1-2 more supporting goals based on what they mentioned
4. Leave key_results with `current: 0` -- they'll fill in over time

Present for review and write.

### Step 4: Create my-tasks.yaml

Create an empty `~/.claude/my-tasks.yaml`:
```yaml
tasks: []
```

### Step 5: MCP Integration Check

Walk through available integrations:

```
The system works best with these integrations (all optional):

1. Gmail -- enables /triage, overnight message scanning in /gm
   Setup: docs/mcp-integrations.md#gmail

2. Google Calendar -- enables calendar-aware scheduling in /gm, /eod
   Setup: docs/mcp-integrations.md#calendar

3. Granola -- enables /reflect, meeting-aware /capture, contact enrichment
   Setup: docs/mcp-integrations.md#granola

Which of these do you have or want to set up?
```

For each they want, point them to the docs. Don't try to configure MCPs
inline -- it requires separate setup.

### Step 6: Quick Diagnostic

Run a quick check:
- Verify CLAUDE.md loads correctly
- Verify my-profile.md exists and is readable
- Verify goals.yaml is valid YAML
- Verify my-tasks.yaml exists
- Check if any MCP servers respond
- Verify scripts are executable (`chmod +x ~/.claude/scripts/*.sh`)

Report results.

### Step 7: First Run

Offer:
```
Setup complete. Your Chief of Staff is ready.

Want me to run /gm for your first morning briefing?
(It won't have much data yet, but it'll show you the format.)
```

### Guidelines

- Keep the conversation natural. This is onboarding, not interrogation.
- Don't ask unnecessary questions. If something can be inferred, infer it.
- The profile should feel like them, not like a template was filled in.
- If they seem unsure about goals, help them think through it. "What would make you feel like this month was a success?"
- Make scripts executable automatically -- don't make them do it manually.
- The whole setup should take < 10 minutes.
