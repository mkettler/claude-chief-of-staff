# /diagnostics -- Weekly System Health Check

## Description
Security audit, MCP health, permissions review, and chief of staff effectiveness.
Run once per week (suggested: Friday afternoon as part of weekly wind-down).

## Instructions

You are running a weekly diagnostic on the Chief of Staff system.
This covers four areas: security, system integrity, MCP health, and effectiveness.

### 1. Security & Permissions Audit

**Check settings.json:**
- Read `~/.claude/settings.json` and review the allow/deny lists
- Flag any permissions that seem too broad for post-setup use
- Verify deny list blocks dangerous operations (rm -rf, sudo, force-push)
- Check if any new tools were auto-allowed during the week that shouldn't persist

**Check for sensitive files:**
- Scan `~/.claude/` for any files that look like credentials, tokens, or secrets
  (*.key, *.pem, *.token, .env, oauth.*.json, credentials.json)
- Check that no contact files contain sensitive data that shouldn't be stored

**Report:**
```
SECURITY
- Permissions: [OK / issues found]
- Sensitive files: [OK / items flagged]
- Data boundaries: [OK / concerns]
```

### 2. System Integrity

**Check file structure:**
- Verify core files exist and are non-empty:
  - ~/.claude/CLAUDE.md
  - ~/.claude/goals.yaml
  - ~/.claude/my-tasks.yaml
  - ~/.claude/commands/ (command files)
- Verify directory structure:
  - ~/.claude/contacts/
  - ~/.claude/logs/daily/
  - ~/.claude/reflections/
  - ~/.claude/inbox/

**Command inventory:**
- List all .md files in `~/.claude/commands/`
- Present the full set with one-line descriptions
- Flag any commands that haven't been used in 14+ days (check daily logs)

**Check for stale data:**
- goals.yaml: when was it last updated? Flag if older than 14 days.
- my-tasks.yaml: any tasks overdue by more than 7 days?
- contacts/: any contact files not updated in 60+ days?

**Report:**
```
INTEGRITY
- Core files: [OK / missing items]
- Directory structure: [OK / missing]
- Commands: [X] total -- [list with one-line descriptions]
  Unused this week: [list or "all active"]
- Stale data: [list items needing refresh]
```

### 2b. System Coherence (/sync)

Run /sync full. Include the output in the diagnostics report.

### 3. MCP Server Health

Check each configured MCP server by attempting a simple operation:

- **Email MCP** -- test search with a simple query
- **Calendar MCP** -- test fetching today's events
- **Meeting history MCP** (Granola) -- test `get_statistics` if available
- **Other MCPs** -- as configured

If an MCP is not configured, note it as "not connected" (not an error).

**Report:**
```
MCP SERVERS
- Email: [OK / error / not connected]
- Calendar: [OK / error / not connected]
- Meeting history: [OK / error / not connected]
- [Others as configured]
```

### 4. Chief of Staff Effectiveness

**Review this week's logs:**
- Read all files in `~/.claude/logs/daily/` from this week
- Count: How many /gm briefings were run? /eod rituals? /triage runs?
- Check: Were Top 3 priorities achieved most days?
- Check: Did any loose threads carry over for more than 2 days?

**Review goals progress:**
- Read `~/.claude/goals.yaml` and assess movement on key results
- Flag any key result that hasn't moved in 2+ weeks

**Capture inbox review:**
- Read all files in `~/.claude/inbox/` (explore-later items)
- For each item, recommend one of:
  - **Promote** -- it's now a task, contact, reflection, or signal
  - **Keep** -- still worth exploring but not yet actionable
  - **Archive** -- stale or no longer relevant

**Pattern check:**
- Are certain tasks consistently avoided?
- Is structure holding (daily rituals happening)?
- Energy patterns: any days with notably low output?

**Report:**
```
EFFECTIVENESS
- Daily rituals: [X/5] mornings, [X/5] check-ins, [X/5] closings
- Top 3 completion rate: [X]%
- Stalled goals: [list or "none"]
- Capture inbox: [X] items -- [Y] to promote, [Z] to archive, [W] to keep
- Patterns: [observations]

RECOMMENDATION
[One specific thing to adjust next week]
```

### Output Format

```
WEEKLY DIAGNOSTICS -- Week of [Date]

SECURITY
[...]

INTEGRITY
[...]

MCP SERVERS
[...]

EFFECTIVENESS
[...]

ACTIONS FOR NEXT WEEK
1. [Most important system adjustment]
2. [Second priority]
3. [Any maintenance needed]
```

### Guidelines

- Be factual, not alarmist.
- The effectiveness section is the most valuable part.
- If rituals aren't being run, don't just note it -- ask why.
- Suggest specific, small adjustments. Not "overhaul the system."
- This is a meta-check. The system should improve itself over time.

### Persistence

Write the full diagnostic to `~/.claude/logs/diagnostics-[date].md`.
