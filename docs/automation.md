# Automation Guide

The Chief of Staff can run commands automatically on a schedule. This is
optional -- most users start with manual invocation and add automation later.

## How It Works

Claude Code can run headlessly via `claude -p "prompt"`. Combined with a
scheduler (cron, launchd), you can automate morning briefings, end-of-day
rituals, and periodic checks.

## Example Scripts

The `scripts/` directory includes example automation scripts:

- `morning-briefing.sh.example` -- runs `/gm` and emails the output
- `eod-ritual.sh.example` -- runs `/eod` in headless mode and emails the output

To use these:
1. Copy and remove the `.example` suffix
2. Edit the configuration variables at the top (email, claude path, working dir)
3. Make executable: `chmod +x scripts/morning-briefing.sh`

## macOS: launchd

Create a plist file at `~/Library/LaunchAgents/com.chief-of-staff.morning.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.chief-of-staff.morning</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>-l</string>
        <string>-c</string>
        <string>~/.claude/scripts/morning-briefing.sh</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>7</integer>
        <key>Minute</key>
        <integer>30</integer>
    </dict>
    <key>StandardOutPath</key>
    <string>/tmp/morning-briefing.stdout</string>
    <key>StandardErrorPath</key>
    <string>/tmp/morning-briefing.stderr</string>
    <key>WorkingDirectory</key>
    <string>/Users/YOUR_USERNAME/Code</string>
</dict>
</plist>
```

Load it:
```bash
launchctl load ~/Library/LaunchAgents/com.chief-of-staff.morning.plist
```

## Linux: cron

```bash
crontab -e

# Morning briefing at 7:30am weekdays
30 7 * * 1-5 /bin/bash -l -c "$HOME/.claude/scripts/morning-briefing.sh"

# EOD ritual at 10pm weekdays
0 22 * * 1-5 /bin/bash -l -c "$HOME/.claude/scripts/eod-ritual.sh"
```

## Task Executor

The `scripts/task-executor.sh` processes delegated tasks automatically.
When you delegate a task to Claude (via `/capture [fc]` or the delegation
system), this script picks it up and executes it.

Run manually:
```bash
~/.claude/scripts/task-executor.sh           # Process all pending
~/.claude/scripts/task-executor.sh --dry-run  # Preview what would run
```

Or schedule it to run periodically (e.g. every 2 hours during work hours).

## Schedules Reference

See `schedules.yaml` for the recommended automation schedule. This file
is a reference -- it doesn't control anything directly. Use it as a guide
when setting up your cron/launchd entries.

## Troubleshooting

**Scripts not running:** Check that the claude binary is in PATH for the
scheduler context. launchd and cron use minimal environments. Use full
paths or set `CLAUDE_BIN` in the script.

**No email delivery:** The email send step requires an email MCP with send
capability. If you don't have one, modify the script to write output to a
file instead.

**Logs:** Check `~/.claude/logs/automated/` for script output and errors.
