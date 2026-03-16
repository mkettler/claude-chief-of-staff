# Claude Chief of Staff

An AI chief of staff built on [Claude Code](https://docs.anthropic.com/en/docs/claude-code). It manages your day, tracks your goals, maintains your network, and keeps you honest about where your time goes.

Not a chatbot. Not a to-do app. A structured system that runs in your terminal, challenges you when you're drifting, and protects your time.

## What it does

**Daily rituals** that create a continuous thread through your day:
- `/gm` -- morning briefing with calendar, messages, goal progress, and today's Top 3
- `/check` -- midday pulse check
- `/eod` -- evening shutdown that clears your head and pre-loads tomorrow

**Task management** that pushes back on vague intentions:
- `/my-tasks` -- track, prioritise, execute, brain-dump
- `/review` -- rapid swipe through open tasks
- `/capture` -- zero-friction brain dump that sorts itself

**Network CRM** for intentional relationship management:
- `/network` -- dashboard with staleness alerts and outreach suggestions
- `/enrich` -- deep-dive on contacts using meeting history
- `/triage` -- scan email channels, draft responses in your voice

**System maintenance** that keeps everything coherent:
- `/sync` -- cross-file consistency checks
- `/diagnostics` -- weekly health audit
- `/precompact` -- context preservation before compaction

**Optional job search module** for career transitions:
- `/job`, `/jobscan`, `/signals` -- pipeline tracking, company intel, market signals

## Quick start

```bash
# Clone to ~/.claude (where Claude Code reads its config)
git clone https://github.com/mkettler/claude-chief-of-staff.git ~/.claude

# Or if you already have a ~/.claude directory, clone elsewhere and symlink
git clone https://github.com/mkettler/claude-chief-of-staff.git ~/claude-chief-of-staff
ln -s ~/claude-chief-of-staff ~/.claude

# Open Claude Code and run setup
claude
> /setup
```

The `/setup` wizard will:
1. Ask you a few questions about who you are and what you're working toward
2. Generate your `my-profile.md` (personal context)
3. Create your `goals.yaml` (objectives and key results)
4. Set up an empty task list
5. Walk through optional MCP integrations
6. Run a quick diagnostic
7. Offer to run your first `/gm` morning briefing

## How it works

The system is a collection of Claude Code [slash commands](https://docs.anthropic.com/en/docs/claude-code/slash-commands) backed by a file-based data layer. No database, no server, no accounts. Everything lives in `~/.claude/` as markdown and YAML files.

```
~/.claude/
  CLAUDE.md              # System instructions (the soul of the system)
  my-profile.md          # Your personal context (created by /setup)
  goals.yaml             # Your objectives and key results
  my-tasks.yaml          # Active task list
  settings.json          # Claude Code permissions and hooks
  commands/              # 14 slash commands + optional modules
  scripts/               # Automation scripts and hooks
  contacts/              # Network contact profiles
  logs/daily/            # Daily ritual logs
  reflections/           # Saved insights from /reflect
  inbox/                 # Unprocessed capture items
  proposals/             # Delegated task proposals
  drafts/                # Message drafts for review
```

### Philosophy

1. **Clarity over comprehensiveness.** Three things that matter, not twenty that exist.
2. **Structure is freedom.** External structure isn't restrictive -- it's what makes productive days possible.
3. **Honest over nice.** "You're avoiding this" is more helpful than "take your time."
4. **Systems compound.** Every interaction makes the system better.
5. **Ship, don't polish.** Bias toward action over perfection.

### The golden rule

You prepare, I execute. You draft, I send. You recommend, I decide. Nothing leaves the system and reaches another human without explicit approval.

## MCP integrations (optional)

The system works without any MCP servers. Adding them unlocks more capability:

| Integration | What it enables |
|-------------|-----------------|
| **Gmail** | Email triage, overnight message scanning, draft responses |
| **Google Calendar** | Calendar-aware scheduling, conflict detection |
| **Granola** | Meeting history search, pattern analysis, contact enrichment |

See [docs/mcp-integrations.md](docs/mcp-integrations.md) for setup instructions.

## Visual dashboard (optional)

Because the data layer is just files on disk (YAML + markdown), you can build a web dashboard on top of it. A Next.js app with API routes that read from `~/.claude/` gives you a visual command centre: task kanban, goal progress bars, contact staleness, proposal review cards, and a brain dump textarea.

See [docs/dashboard.md](docs/dashboard.md) for the full architecture, API route patterns, data types, and how to build your own.

## Automation (optional)

Morning briefings and end-of-day rituals can run automatically via launchd (macOS) or cron (Linux). See [docs/automation.md](docs/automation.md).

## Customization

Everything is yours to modify. See [docs/customization.md](docs/customization.md) for:
- Adding custom commands
- Modifying existing workflows
- Configuring contact categories
- Enabling/disabling modules

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed
- A Claude API key or Claude Pro/Team subscription
- macOS or Linux (Windows via WSL should work but is untested)

## License

MIT
