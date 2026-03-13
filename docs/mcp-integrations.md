# MCP Integrations

The Chief of Staff works without any MCP servers, but adding them unlocks
significant capability. Commands gracefully skip unavailable integrations.

## Gmail

**What it enables:** `/triage`, overnight message scanning in `/gm`, draft
responses, email search.

**Setup:**
1. Install a Gmail MCP server (e.g. the official Google Workspace MCP)
2. Configure OAuth credentials following the MCP server's instructions
3. Add the tool names to `settings.json` allow list:
   ```json
   "mcp__your-gmail-mcp__*"
   ```

**Multiple accounts:** If you have separate personal and work email, you can
configure multiple Gmail MCP servers. Update the command files (`gm.md`,
`triage.md`, `check.md`, `eod.md`) to reference both sets of tools.

**Security note:** The system never sends email without explicit approval.
Add only read and draft tools to the allow list. Keep send/delete tools
behind the approval prompt.

## Google Calendar

**What it enables:** Calendar-aware scheduling in `/gm` and `/eod`, conflict
detection, meeting prep suggestions.

**Setup:**
1. Install a Google Calendar MCP server
2. Configure OAuth credentials
3. Add read tools to `settings.json` allow list:
   ```json
   "mcp__your-calendar-mcp__list_events",
   "mcp__your-calendar-mcp__get_event"
   ```

**Security note:** Keep calendar write tools (create, delete, update, respond)
OUT of the allow list. The system should never modify your calendar without
asking.

## Granola (Meeting History)

**What it enables:** `/reflect`, meeting-aware `/capture`, contact enrichment
via `/enrich`, action item tracking in `/gm` and `/eod`.

**Setup:**
1. Install the Granola MCP server (github.com/andybrandt/GranolaMCP or similar)
2. Point it at your Granola cache file (usually at
   `~/Library/Application Support/Granola/cache-v4.json` on macOS)
3. Add to `settings.json` allow list:
   ```json
   "mcp__granola__*"
   ```

**Search patterns:** The system uses dual search (participant filter + query
filter) to maximise coverage. This is built into the command files.

## Other Integrations

The system is designed to work with any MCP server. To add a new one:

1. Install and configure the MCP server
2. Add its tools to `settings.json` allow list (read tools only; keep write
   tools behind approval)
3. Update relevant command files to use the new tools

**Examples of useful additions:**
- Slack MCP -- for team communication triage
- Linear/Jira MCP -- for project management integration
- Notion MCP -- for document management
- WhatsApp MCP -- for personal message triage

## Verifying Integration Health

Run `/diagnostics` to check which MCP servers are responding. The MCP
health section tests each configured server with a simple operation.
