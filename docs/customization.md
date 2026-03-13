# Customization Guide

## How the system personalises

The Chief of Staff is designed as a framework that adapts to you, not a
template you fill in. Here's how personalisation works:

### my-profile.md

This is the only file you need to create. It tells the system:
- Who you are (name, role, situation)
- How you work (communication style, energy patterns, boundaries)
- What you're working toward (goals, priorities)
- Your working patterns (what you procrastinate on, what energises you)

Run `/setup` to create this interactively, or copy `my-profile.md.example`
and edit it manually.

### goals.yaml

Your goals drive everything. The system uses them to:
- Align every task to a goal (orphan tasks get flagged)
- Track progress in morning briefings
- Prioritise your Top 3 each day
- Alert you when goals are stalling

Start with `goals.yaml.example` and adapt. Key structure:
- One `primary_goal` -- the thing that matters most right now
- 3-5 `supporting_goals` -- things that enable or complement the primary goal

### settings.json

This controls Claude Code permissions. The shipped version is comprehensive
but conservative. To customise:

**Adding MCP permissions:** When you set up Gmail, Calendar, or Granola MCPs,
add their tool names to the allow list:

```json
"mcp__your-mcp-name__*"
```

**Tightening permissions:** If you don't need certain Bash commands, remove
them from the allow list.

**Adding project-specific scripts:** Add paths to the allow list:
```json
"Bash(~/.claude/scripts/your-script.sh)"
```

## Adding custom commands

Create a `.md` file in `~/.claude/commands/` with this structure:

```markdown
# /command-name -- Short Description

## Description
One-line description shown in command listing.

## Arguments
- `arg1` -- what it does
- (no argument) -- default behaviour

## Instructions

[What Claude should do when this command runs]
```

Claude Code auto-discovers command files in this directory.

## Modifying existing commands

Every command file is yours to edit. Common modifications:
- Changing the output format
- Adding or removing steps
- Adjusting thresholds (staleness days, outreach targets)
- Adding integrations specific to your setup

## Contact categories

The default categories are:
- Active opportunities
- Warm network
- Dormant but valuable
- Industry contacts

Change these in `/network` and `/enrich` command files to match your needs.

## Enabling the job search module

The `commands/modules/job-search/` directory contains optional commands for
career transitions. They're automatically available when present. The `/gm`
morning briefing detects this module and includes pipeline status.

To disable: move the module directory elsewhere or delete it.
