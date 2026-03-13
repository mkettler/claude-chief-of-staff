# Chief of Staff System -- User Guide

## Core Architecture

Everything runs through Claude Code in the terminal. The system is built around **slash commands**, a **file-based data layer**, and optional **MCP integrations** for external data. Nothing leaves your system without your explicit approval.

---

## Daily Rituals (the backbone)

| Command | When | Time | What it does |
|---------|------|------|--------------|
| `/gm` | Morning | ~5 min read | Full briefing: calendar, overnight messages, goal pipeline, Top 3 for today, one challenge (thing you're avoiding). Writes to daily log. |
| `/check` | Midday | ~2 min read | Quick pulse: progress on Top 3, Tier 1 inbound only, 1-2 afternoon tasks. Appends to daily log. |
| `/eod` | Evening | ~5 min | What got done, what didn't and why, loose threads, tomorrow's draft Top 3, final brain dump, one good thing. Clears your head for personal time. |

These three create a continuous thread through the day via daily logs. Each one reads the output of the previous one.

---

## Network & Outreach Commands

| Command | What it does |
|---------|--------------|
| `/network` | Lightweight CRM dashboard. Shows who needs outreach, staleness alerts (14/30/60 day thresholds by contact category), weekly outreach count vs target. `/network add [name]` creates a contact with meeting history + web research. `/network [name]` shows status and suggests next action. |
| `/enrich` | Deep-dive on a specific contact. Pulls meeting history (dual search), web research for Director+ contacts, email/calendar scan. Also `/enrich stale` to find contacts overdue for engagement. |
| `/triage` | Scans email channels, classifies into Tier 1 (act now) / Tier 2 (today) / Tier 3 (archive). Drafts send-ready responses in your voice. Modes: `quick` (Tier 1 only), `digest` (summaries), default (full). Hard 30-minute cap. |

---

## Thinking & Capture Commands

| Command | What it does |
|---------|--------------|
| `/capture` | Zero-friction brain dump. Accepts raw text or picks up Granola voice memos. Sorts items into tasks, contacts, reflections, signals, or inbox. Won't write anything without your confirmation. |
| `/reflect` | Queries meeting history for patterns: leadership style, impact stories, energy mapping, relationship insights. Saves findings to `reflections/`. Feeds narrative building and interview prep. |
| `/my-tasks` | Task management. Modes: `list`, `add`, `complete`, `execute` (picks highest priority and works on it), `dump` (brain dump then sort), `overdue`. Pushes back on vague tasks. |
| `/review` | Rapid task review -- swipe through open tasks one at a time: done, act on it, skip, or drop. Ends with brain dump prompt. |

---

## System Maintenance Commands

| Command | What it does |
|---------|--------------|
| `/sync` | Coherence check across all files. Catches count mismatches, stale dates, contradictions, convention drift. Modes: full, quick, fix. |
| `/diagnostics` | Weekly health check (Friday afternoons). Security audit, file integrity, MCP server tests, effectiveness review (ritual adherence, outreach targets, stalled goals, inbox review). |
| `/precompact` | Runs before context compaction. Reviews session for durable learnings to save to MEMORY.md. Writes session summary. |
| `/catchup` | Cross-session context rebuild. Reads session summaries, task changes, proposals, and git activity to reconstruct what happened. |

---

## Optional Modules

### Job Search (`commands/modules/job-search/`)

| Command | What it does |
|---------|--------------|
| `/job` | Tracks opportunities in `jobs.md`. Accepts URLs or pasted listings. Extracts structured details. Updates status (considering > applied > interviewing > offer/rejected). |
| `/jobscan` | Live web intelligence on tracked companies. Also scans for new roles and suggests companies not yet on your radar. Runs inline with /gm. |
| `/signals` | Broader market scan: job postings at priority companies, industry trends, network moves. Quality over quantity. |

---

## Data Layer (files)

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Master instructions. Voice, rules, permissions, philosophy. |
| `my-profile.md` | Who you are. Created by /setup. |
| `goals.yaml` | Objectives and key results |
| `my-tasks.yaml` | Active task list with priority, status, due dates, goal alignment |
| `contacts/` | Individual contact profiles |
| `reflections/` | Saved insights from /reflect |
| `logs/daily/` | Daily logs from /gm, /check, /eod |
| `inbox/` | Unprocessed capture items |
| `proposals/` | Claude-delegated task proposals |
| `drafts/` | Message drafts for review |

---

## MCP Integrations

| Integration | What it provides |
|-------------|-----------------|
| **Email (Gmail)** | Read, search, draft. Full triage capability. |
| **Calendar** | Read events, check conflicts. Calendar-aware scheduling. |
| **Granola** | Meeting history, transcripts, semantic search, pattern analysis. |

All integrations are optional. The system works without them -- commands gracefully skip unavailable data sources.

See `docs/mcp-integrations.md` for setup instructions.

---

## What the System Can't Do

- **Send anything on your behalf.** All outreach, emails, messages require your explicit approval.
- **Access LinkedIn directly.** No LinkedIn MCP. All LinkedIn actions are manual.
- **Real-time notifications.** It's pull-based. You run commands, it responds.
- **Access private/authenticated web pages.** WebSearch works for public content only.
- **Track responses automatically.** When someone replies, you need to tell the system or it picks it up during /triage.
- **Cross-session continuity without rituals.** MEMORY.md and daily logs are the bridge. If you skip /eod, context gets lost. If you skip /gm, you start cold.
