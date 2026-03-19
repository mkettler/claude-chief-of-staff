# Architecture

This document explains the design decisions behind the Chief of Staff system -- the "why" behind the "what." The README covers features and setup. This covers the structural choices that make the system work, and that you'd need to understand to run it effectively or extend it.

Everything here is optional. The system works out of the box with `git clone` and `/setup`. But understanding these decisions will help you get more out of it, avoid common pitfalls, and make better choices when customising.

---

## Table of contents

1. [File-based persistence](#1-file-based-persistence)
2. [Git as backup and audit trail](#2-git-as-backup-and-audit-trail)
3. [Daily log as cross-session bridge](#3-daily-log-as-cross-session-bridge)
4. [Context window management](#4-context-window-management)
5. [Tiered memory durability](#5-tiered-memory-durability)
6. [Self-correcting counts](#6-self-correcting-counts)
7. [Script extraction for permission bypass](#7-script-extraction-for-permission-bypass)
8. [Deny list as security boundary](#8-deny-list-as-security-boundary)
9. [Effort level configuration](#9-effort-level-configuration)
10. [Model selection for automation](#10-model-selection-for-automation)
11. [Proposal system as delegation contract](#11-proposal-system-as-delegation-contract)
12. [The one exception to the golden rule](#12-the-one-exception-to-the-golden-rule)
13. [Dual-search pattern for meeting history](#13-dual-search-pattern-for-meeting-history)
14. [launchd over cron](#14-launchd-over-cron)
15. [Obsidian vault overlay](#15-obsidian-vault-overlay)
16. [Coherence over comprehensiveness](#16-coherence-over-comprehensiveness)

---

## 1. File-based persistence

**Decision:** All state lives as YAML and markdown files on disk. No database, no cloud service, no sync layer.

**Why:** The data layer needs to be readable by both Claude Code (terminal) and optionally a web dashboard, without either owning the schema. Flat files achieve this naturally. YAML is structured enough for tasks and goals. Markdown is flexible enough for contacts, logs, and reflections. Both are human-readable, diffable, and editable in any text editor.

**Tradeoff:** No indexing, no query engine, no referential integrity. A 50KB `my-tasks.yaml` file works fine for hundreds of tasks, but this approach wouldn't scale to thousands of records. For a personal system, that limit is unlikely to matter.

**Alternative considered:** SQLite. Would give proper queries and constraints, but loses human readability and makes the data opaque to Obsidian, VS Code, and grep.

**Optional.** This is baked into the system design, but if you outgrow flat files, you could swap the data layer without changing the command structure. The dashboard doc (`docs/dashboard.md`) discusses this tradeoff.

---

## 2. Git as backup and audit trail

**Decision:** The `~/.claude/` directory should be a git repository with a private remote. Commands like `/eod` and `/precompact` auto-commit after writing.

**Why:** Three problems solved at once:
- **Recovery.** If a file gets corrupted or accidentally overwritten, `git log` and `git checkout` bring it back.
- **Audit trail.** You can see exactly what changed and when. Useful for reviewing how goals evolved, when contacts were added, or what a daily log looked like before edits.
- **Remote backup.** Push to a private GitHub repo and your entire system survives a disk failure.

**How to set up:**

```bash
cd ~/.claude
git init
git remote add origin git@github.com:YOUR_USERNAME/claude-config.git
echo "projects/*/sessions/" >> .gitignore
echo "projects/*/*.jsonl" >> .gitignore
echo ".credentials/" >> .gitignore
echo "*.tmp" >> .gitignore
echo "*.tokens" >> .gitignore
echo "plugins/" >> .gitignore
git add -A && git commit -m "initial commit"
git push -u origin main
```

**Auto-commit pattern:** Add git commit steps to `/eod` and `/precompact` so the system self-backs-up as part of daily rituals. The closing ritual is a natural checkpoint -- you're done for the day, commit the state.

**Optional.** The system works without git. You lose history and backup, but all commands function identically.

---

## 3. Daily log as cross-session bridge

**Decision:** The `/gm` -> `/check` -> `/eod` chain writes to the same daily log file (`logs/daily/YYYY-MM-DD.md`), and each command reads the output of the previous one. The next morning's `/gm` reads yesterday's log.

**Why:** This is the system's continuity mechanism. Claude Code sessions don't persist across restarts. Context compaction erases earlier conversation. The daily log is what survives.

The chain works like this:

```
Day 1, morning:  /gm writes "Top 3" and "Challenge" to logs/daily/2026-03-17.md
Day 1, midday:   /check reads the Top 3, appends progress update
Day 1, evening:  /eod reads the full day's log, writes "Loose threads" and "Tomorrow's draft Top 3"
Day 2, morning:  /gm reads yesterday's log, picks up loose threads and draft Top 3
```

This means:
- Skipping `/eod` breaks the thread. Tomorrow's `/gm` starts cold.
- The daily log IS the handoff mechanism. It's not a nice-to-have output -- it's structural.

**Why this matters:** Without this pattern, every session starts from scratch. You'd re-read goals, re-check calendar, re-assess priorities. The daily log thread means `/gm` can say "yesterday you planned to do X, Y, Z -- here's what carried over" instead of generating a fresh briefing with no memory of what you intended.

**Optional.** The commands work without this chain, but you lose the single most valuable property of the system: continuity across sessions and days.

---

## 4. Context window management

**Decision:** Three hooks work together to manage Claude Code's context window: a status line showing live usage, a warning at 80%, and a pre-compaction checkpoint.

**Why:** Claude Code compacts conversation history when the context window fills up. This is destructive -- earlier tool results, file reads, and reasoning get summarised or dropped. For a system that accumulates state across a session (daily logs, task updates, contact research), losing context mid-session means losing work.

**The three mechanisms:**

| Hook | Trigger | What it does |
|------|---------|--------------|
| **Status line** | Continuous | Shows context % in the terminal status bar via `context-status.sh` |
| **Stop hook** | 80% context used | Runs `context-check.sh`, warns you that compaction is approaching |
| **PreCompact hook** | Before compaction | Runs `pre-compact-hook.sh`, writes a snapshot to `logs/compaction/` |

**How to enable:** These are already wired in the shipped `settings.json`. The scripts are in `scripts/`.

**The workflow when context gets high:**
1. Status line shows you're at 75%, 80%, 85%...
2. Stop hook fires a warning: "Context is high, consider running /precompact"
3. You run `/precompact`, which saves session learnings to MEMORY.md and writes a session summary
4. When compaction happens, the next `/catchup` command reads session summaries to rebuild context

**Optional.** Without these hooks, compaction still happens -- you just lose awareness of when it's coming and what got lost. The hooks turn a disruptive event into a managed transition.

---

## 5. Tiered memory durability

**Decision:** The system has three tiers of persistence with different lifetimes:

| Tier | Location | Lifetime | Purpose |
|------|----------|----------|---------|
| **Session snapshots** | `logs/sessions/` | 7 days | What happened in a specific Claude Code session |
| **Daily logs** | `logs/daily/` | Permanent | What happened on a specific day |
| **MEMORY.md** | `projects/*/memory/MEMORY.md` | Permanent (curated) | Durable system knowledge that applies across all sessions |

**Why:** Not everything is worth remembering forever. Session snapshots capture "I was working on X and got to Y" -- useful for the next session, irrelevant after a week. Daily logs capture "on March 17 I did X, Y, Z" -- useful for weekly reviews and pattern detection. MEMORY.md captures "this is how the system works, this is what the user prefers" -- the operating manual that every future session needs.

**The 7-day TTL on session snapshots** prevents unbounded growth. Without it, `logs/sessions/` would accumulate hundreds of files that nobody reads. The TTL can be adjusted -- check `/precompact` for the cleanup logic.

**The 200-line limit on MEMORY.md** forces curation. Claude Code loads MEMORY.md into every conversation. If it grows to 500 lines of stale notes, it wastes context window on irrelevant information. The `/precompact` command checks line count and flags when it's getting long.

**Optional.** The system works without session snapshots or strict TTLs. But without the tiered model, you either lose everything (no snapshots) or accumulate everything (no cleanup).

---

## 6. Self-correcting counts

**Decision:** When commands update metrics in `goals.yaml` (contacts tracked, pipeline count, outreach sent), they recount from the source of truth instead of incrementing.

**Example:**

```yaml
# Instead of this (drift-prone):
current: 22  # was 21, added one

# The system does this:
current: 23  # counted: ls ~/.claude/contacts/*.md | wc -l
```

**Why:** Incrementing drifts. If a command fails mid-execution, or if you manually add a contact, or if two sessions run concurrently, the count goes wrong. Recounting from files is always accurate.

**Where it applies:**
- `/network add` recounts contact files after creating one
- `/job` recounts pipeline entries after adding/updating
- `/capture` recounts after processing items into contacts or tasks

**Tradeoff:** Slightly slower (reads directory listing instead of incrementing a number). Negligible for the file counts involved.

**Optional.** You can use simple increments if you prefer. The risk is that counts in `goals.yaml` gradually diverge from reality, and `/sync` will flag the discrepancy.

---

## 7. Script extraction for permission bypass

**Decision:** Complex shell logic lives in standalone scripts (`scripts/`, `~/bin/`) that are explicitly allowlisted in `settings.json`, rather than written as inline bash commands.

**Why:** Claude Code's permission model works per-command. A simple `git status` is auto-allowed. But a compound command like `git status && git diff --stat && git log --oneline -5` needs user approval every time because it chains multiple operations. This creates friction in commands that run daily.

**The workaround:**
1. Write the compound logic as a script (e.g., `scripts/git-health-check.sh`)
2. Add it to the settings.json allow list: `"Bash(~/.claude/scripts/git-health-check.sh)"`
3. Now Claude can execute it without prompting

**Scripts shipped:**

| Script | Purpose | Used by |
|--------|---------|---------|
| `git-health-check.sh` | Check repos for uncommitted/unpushed changes | `/gm`, `/eod` |
| `pre-compact-hook.sh` | Write compaction checkpoint | PreCompact hook |
| `context-check.sh` | Warn about context usage | Stop hook |
| `context-status.sh` | Show live context % | Status line |
| `task-executor.sh` | Process delegated tasks | Automation / manual |
| `morning-briefing.sh.example` | Headless morning briefing | launchd / cron |
| `eod-ritual.sh.example` | Headless closing ritual | launchd / cron |

**Optional.** You can skip this entirely and approve compound commands manually each time. The scripts are a convenience optimisation for daily-driver use.

---

## 8. Deny list as security boundary

**Decision:** The `settings.json` deny list blocks specific command patterns that could be dangerous if Claude executed them autonomously.

**What's blocked and why:**

| Pattern | Risk |
|---------|------|
| `*\| bash*`, `*\| sh*`, `*\| eval*` | Pipe-to-shell injection. Prevents output from one command being executed as code. |
| `git push --force`, `git reset --hard` | Destructive git operations that lose history |
| `git checkout .`, `git restore .`, `git clean -f` | Discard all uncommitted work |
| `> ~/.bashrc`, `>> ~/.zshrc`, etc. | Shell config modification. Prevents persistent environment changes. |
| `npm install -g`, `pip install --user` | Global package installation. Prevents system-wide side effects. |
| `sudo` | Privilege escalation |
| `rm -rf /`, `rm -rf /*` | Catastrophic deletion |

**Why this matters:** Claude Code operates with your user permissions. It can read, write, and execute anything you can. The deny list is the only thing preventing an accidental (or prompt-injected) destructive operation. If you remove rules you don't understand, you remove protections.

**Optional.** The deny list ships pre-configured. You can tighten it (add more patterns) or loosen it (remove patterns you find too restrictive). But understand the risk before removing pipe-to-shell or force-push blocks.

---

## 9. Effort level configuration

**Decision:** Claude Code supports an `effortLevel` setting in `settings.json` that controls how thorough and autonomous the AI behaves. Setting it to `"high"` makes Claude more comprehensive in its responses, more willing to take multiple steps autonomously, and less likely to stop and ask for confirmation on intermediate steps.

**How to enable:**

Add to your `settings.json`:
```json
{
  "effortLevel": "high"
}
```

**Why you might want this:** The Chief of Staff system involves multi-step commands that read from several sources, cross-reference data, and produce structured output. At default effort, Claude may take shortcuts, produce thinner analysis, or stop mid-command to ask if you want it to continue. At high effort, it completes the full command spec without prompting.

**Tradeoff:** Higher token usage per interaction. Responses take longer. For quick questions unrelated to the CoS system, high effort is overkill.

**The shipped `settings.json` does not include this setting** to keep the default experience lightweight. Add it after you've used the system for a few days and want deeper output from commands like `/gm`, `/reflect`, and `/enrich`.

**Optional.** Entirely a preference. The system works at any effort level.

---

## 10. Model selection for automation

**Decision:** When running commands headlessly via `claude -p` (for automation scripts like morning briefings), the model choice matters. More capable models (Opus) produce significantly better output for complex commands that cross-reference multiple data sources. Smaller models may miss connections or produce thinner analysis.

**How to configure:**

In your automation scripts, specify the model:
```bash
claude -p "Run /gm" --model opus
```

**Why this matters:** A morning briefing reads from calendar, email, task list, goals, yesterday's log, and meeting history. It needs to synthesise these into a coherent 5-minute read with specific, actionable priorities. A less capable model may list data sources without synthesising, miss overdue items, or produce generic Top 3 priorities instead of ones grounded in your actual state.

**Tradeoff:** Cost and speed. Opus is more expensive and slower. For simple commands (`/check`, quick `/triage`), a smaller model works fine.

**Optional.** The system works with any model. This is a quality-of-life optimisation for heavy commands run in automation.

---

## 11. Proposal system as delegation contract

**Decision:** When you delegate a task to Claude (via `/capture [fc]` or `delegate_to_claude: true`), the system requires three artifacts for the work to be considered complete and visible:

```
1. Task entry in my-tasks.yaml     (status: delegated)
2. Proposal YAML in proposals/     (execution details + deliverables)
3. Output files                    (the actual work product)
```

**Why three artifacts:** Each serves a different audience:
- The **task entry** tracks what was requested and its status in the overall task list
- The **proposal file** is the review interface -- it describes what was done, how, and where the output is. Without it, completed work is invisible on the dashboard's "Proposals for review" tab.
- The **output files** are the actual deliverables (contact profiles, research docs, etc.)

**What happens without the proposal file:** The task shows in "Claude's queue" but never moves to "Review." You don't know it's done. `/sync` Layer 1.5 catches this misalignment and flags it.

**Proposal file structure:**
```yaml
id: prop-20260315-001
task_id: task-042
title: "Research company X for job application"
status: completed
created: "2026-03-15"
execution_path: A   # A=done review only, B=autonomous, C=needs terminal
summary: |
  Researched company X. Created contact profiles for two hiring managers.
  Identified three talking points for outreach.
deliverables:
  - path: /absolute/path/to/contacts/hiring-manager.md
    description: Contact profile with career arc and outreach angle
```

**Important:** All file paths in proposals must be absolute (`/Users/you/.claude/...`), not relative. Relative paths break cmd-click navigation in VS Code and terminal.

**Optional.** You can delegate tasks without the full proposal system. But the three-artifact pattern is what makes async human-AI delegation auditable and reviewable.

---

## 12. The one exception to the golden rule

**Decision:** The golden rule is "nothing leaves the system without explicit approval." The morning briefing automation is the one exception: it sends an email to your own inbox without asking.

**Why:** The morning briefing runs at 7:30am before you're at your desk. Its entire purpose is to have a briefing waiting for you when you start your day. Requiring approval would defeat the purpose -- you'd need to be at your terminal to approve the send, at which point you could just run `/gm` interactively.

**Why this is safe:** The recipient is you. The content is a summary of your own calendar, tasks, and messages. There's no external audience, no reputation risk, no undo needed.

**How it works:** The `morning-briefing.sh` script runs `/gm` headlessly, captures the output, and sends it via an email MCP tool. If no email MCP is configured, the script writes to a log file instead.

**Optional.** If you're uncomfortable with any autonomous sends, modify the script to write to a file or push a notification instead of emailing. The `/gm` command itself never sends anything -- only the automation wrapper does.

---

## 13. Dual-search pattern for meeting history

**Decision:** When searching meeting transcripts (via Granola or similar MCP), always run two searches and deduplicate the results.

**The pattern:**
```
Search 1: participant filter with email address
  -> Finds meetings where the person was recorded as a participant

Search 2: query filter with their name (and "Name / Your Name" title pattern for 1:1s)
  -> Finds meetings where the title or content mentions them
  -> Catches older meetings where participant metadata is missing
```

**Why both:** Meeting tools often have incomplete metadata for older meetings. Participant lists may be empty (`participant_count: 0`) even when the person was clearly in the meeting. Title-based search catches these. But title-based search misses group meetings where the person isn't in the title. You need both.

**Where this applies:**
- `/network add` (building a contact profile from meeting history)
- `/enrich` (deep-dive on a contact)
- `/reflect` (pattern analysis across meetings)
- `/feedback` (evidence gathering for peer reviews)

**Fallback:** If semantic search silently fails (returns empty or errors), fall back to listing all meetings in a date range and filtering client-side by name.

**Optional.** If your meeting tool has reliable participant metadata, a single search may suffice. But if you notice missing meetings in contact profiles, enable dual search.

---

## 14. launchd over cron

**Decision:** On macOS, the automation docs recommend launchd (via plist files in `~/Library/LaunchAgents/`) over crontab.

**Why:** launchd handles sleep/wake correctly. If your Mac is asleep at 7:30am and wakes at 8:15am, launchd runs the missed job. cron does not -- the 7:30am slot is simply skipped.

For a morning briefing that should be waiting when you open your laptop, this difference matters. Missing the briefing because your laptop was in sleep mode defeats the purpose.

**Other advantages:**
- Native macOS integration (logs via `log show`, managed via `launchctl`)
- Per-user agents don't need root/sudo
- Process environment is more predictable than cron's minimal shell

**Tradeoff:** More verbose configuration (XML plist vs one-line crontab). Debugging is less intuitive than `crontab -l`.

**On Linux:** Use cron. The automation doc (`docs/automation.md`) includes both setups.

**Optional.** Use whichever scheduler you prefer. The scripts work with either.

---

## 15. Obsidian vault overlay

**Decision:** The `~/.claude/` directory can double as an [Obsidian](https://obsidian.md) vault, making all files navigable through Obsidian's graph view and backlinks.

**How:** Use `[[wiki links]]` between related files. When a contact file references a reflection, link it: `See [[reflections/2026-03-15-narrative-work|narrative session]]`. When a daily log mentions a contact, link it: `Followed up with [[contacts/sara-spannar|Sara]]`.

**What this gives you:**
- **Graph view** showing connections between contacts, reflections, tasks, and logs
- **Backlinks** showing everywhere a contact or project is referenced
- **Quick navigation** via Obsidian's link-click and search
- **Tag-based views** if you add tags to markdown files

**Setup:** Open `~/.claude/` as a vault in Obsidian. No plugins required for basic navigation. The graph view works immediately with wiki links.

**Optional.** The system works without Obsidian. Wiki links are ignored by Claude Code and by the dashboard. This is purely a human navigation layer.

---

## 16. Coherence over comprehensiveness

**Decision:** The system actively checks itself for internal consistency via `/sync`, rather than relying on completeness.

**Why:** A file-based system with 20+ commands writing to shared files will drift. Contact counts in `goals.yaml` will disagree with the actual number of files in `contacts/`. Task statuses will fall out of sync with proposal statuses. Dates will go stale.

Rather than preventing drift (which is impossible in a multi-writer system), the architecture accepts drift and corrects it. `/sync` runs five layers of checks:

| Layer | What it checks |
|-------|---------------|
| 1. Counts | Do numbers in goals.yaml match actual file counts? |
| 1.5. Proposals | Do proposal files exist for all delegated tasks? Are statuses aligned? |
| 2. Dates | Are goals.yaml, MEMORY.md, and contacts recently updated? Any overdue tasks? |
| 3. Content | Does CLAUDE.md agree with goals.yaml? Any dead file references? |
| 4. Conventions | Are goal alignment values consistent? Status values valid? |
| 5. Bloat | Is CLAUDE.md getting too long? Too many completed tasks? Inbox piling up? |

**The principle:** Two files that disagree are worse than one missing file. Contradictions erode trust in the system. `/sync` finds contradictions so you can resolve them before they compound.

**When to run:** Weekly as part of `/diagnostics`, or anytime the system feels "off." Quick mode (Layers 1-2) takes seconds. Full mode takes a minute.

**Optional.** The system works without `/sync`. Files will gradually drift. How much this bothers you depends on how much you rely on the numbers in `goals.yaml` and the accuracy of contact staleness alerts.

---

## Summary

These decisions fall into three categories:

**Persistence and continuity** (1-5): How the system survives across sessions, days, and compactions. The daily log bridge (#3) is the most important single pattern.

**Security and permissions** (6-10): How the system balances autonomy with safety. The deny list (#8) and script extraction (#7) work together to give Claude broad capability without dangerous edge cases.

**Coordination and governance** (11-16): How the system keeps human and AI work aligned. The proposal contract (#11) and coherence checks (#16) prevent the system from doing invisible or contradictory work.

Everything is optional. The system works as a simple slash command collection with zero configuration. Each decision here adds a layer of robustness for people who want to run it as a daily-driver operating system.
