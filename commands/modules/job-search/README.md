# Job Search Module

Optional commands for people in career transition. These add job pipeline
tracking, market intelligence, and opportunity scanning to the Chief of Staff.

## How to Enable

These commands are automatically available when placed in `commands/modules/job-search/`.
Claude Code discovers them from this path. The `/gm` morning briefing will
detect this module and include pipeline status when it exists.

## Commands

- `/job` -- Track opportunities from discovery through application
- `/jobscan` -- Active intelligence on tracked companies and market signals
- `/signals` -- Broader industry scan for opportunities and trends

## Required Files

When you start using these commands, they'll create:

- `~/.claude/jobs.md` -- Job pipeline tracker (markdown table)
- `~/.claude/signals.md` -- Captured market signals

## Setup

1. Copy these command files to your `~/.claude/commands/modules/job-search/` directory
   (or leave them here if your `~/.claude/` IS this repo)
2. Update your `goals.yaml` to include job-search-related goals and key results
3. Start tracking with `/job [URL or pasted listing]`

## Customisation

The commands reference target roles and markets from `goals.yaml`. Update your
goals file to set:
- Target role titles
- Target locations/markets
- Priority companies to monitor
