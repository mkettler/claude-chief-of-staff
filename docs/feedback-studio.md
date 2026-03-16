# Building a Peer Feedback Studio

A standalone tool for writing structured peer feedback backed by AI-gathered
evidence. Designed for performance review cycles where you need to write
thoughtful feedback for multiple colleagues based on months of collaboration.

## The idea

Writing good peer feedback is hard because the evidence is scattered across
meetings, emails, and chat messages. By the time review season arrives,
you've forgotten the specific moments that matter.

This tool solves that in three layers:

1. **Evidence gathering** -- Claude pulls raw observations from meeting
   transcripts, email threads, and chat messages
2. **Pre-analysis** -- Claude synthesises the evidence into themes, strengths,
   growth areas, and watch-outs
3. **Human writing** -- you write the final feedback in a structured editor
   with the evidence and analysis visible alongside, then copy it to your
   HR system

The AI does the research. You write the feedback. The result is specific,
evidence-backed, and genuine.

## Architecture

```
Claude Code (/feedback command)
    |
    | writes evidence + analysis files
    |
drafts/ directory (markdown files)
    |
    | read by
    |
Node.js API server (port 3847)
    |
    | fetch / save
    |
React dashboard (Vite, port 5173)
```

**Tech stack:**
- React (Vite) -- frontend
- Node.js (native http, no framework) -- API server
- Filesystem persistence -- no database
- Vite dev proxy -- routes `/api/*` to the Node backend

Both servers run simultaneously. The Vite dev server handles the frontend
and proxies API calls to the Node backend.

## Data model

### Peer registry (peers.json)

```json
{
  "peers": [
    {
      "id": 1,
      "name": "Alex Chen",
      "tier": "org",
      "role": "Senior Product Designer",
      "focusArea": "",
      "peerRequestedFocus": "",
      "status": "pending",
      "isLead": false,
      "isDirectReport": true,
      "grade": "L5",
      "jobFamily": "Product Design",
      "reviewAs": "direct report"
    }
  ]
}
```

**Tiers** control depth of feedback:
- `org` -- your team, direct reports, leadership chain (deep feedback)
- `heavy` -- close cross-functional collaborators (medium depth)
- `light` -- occasional collaborators (focused, brief feedback)

**Statuses:** `pending` -> `in_progress` -> `done`

The API enriches each peer with a slug and file existence flags:
```json
{
  "slug": "alex-chen",
  "files": {
    "hasEvidence": true,
    "hasAnalysis": true,
    "hasDraft": false
  }
}
```

### File structure (per peer)

```
drafts/
  alex-chen-evidence.md     # Raw evidence from meetings/email/chat
  alex-chen-analysis.md     # Claude's synthesis
  alex-chen.md              # Final feedback draft
  alex-chen.prev.md         # Backup of previous draft version
```

### Evidence file format

```markdown
# Evidence: Alex Chen
Pulled: 2026-03-05

## Meeting History (42 found -- 15 weekly 1:1s + 27 shared group meetings)

### Jun 2025 - Feb 2026 -- Weekly 1:1s (15 sessions)

**Recurring themes:** ownership of the design system, cross-team
collaboration patterns, mentoring junior designers...

**Key moments:**
- Sep 12: Pushed back on the VP's timeline, proposed phased rollout...
- Nov 3: Led the accessibility audit without being asked...

## Email Threads

### Re: Design System v3 Rollout (Aug-Oct)
Initiated the thread, kept stakeholders informed weekly...

## Chat Messages

### Daily collaboration patterns
Fast responder, uses threads consistently, escalates blockers early...
```

### Analysis file format

```markdown
# Pre-Analysis: Alex Chen

## What I Know
- Consistently takes ownership beyond their scope...
- Strong technical communication in written channels...

## Growth Areas
- Tends to take on too much; delegation is a development area...
- Could be more vocal in group settings...

## Watch-Outs
- Recency bias: the design system launch was recent and visible,
  but don't overlook steady Q2 work on accessibility...
- Your relationship is close; balance warmth with directness...
```

### Draft file format

```markdown
# Feedback Draft: Alex Chen

Saved: 2026-03-05T17:57:33.101Z

---

## Q1: Focus Area

Design system v3 rollout and accessibility standards

## Q2: Accomplishments

[Your written feedback here]

## Q3: Key Strengths

[Your written feedback here]

## Q4: Areas for Growth

[Your written feedback here]

## Q5: Additional Observations

[Your written feedback here]
```

The `## Q1:` through `## Q5:` headers are the parsing contract between
the file format and the UI. Customise the questions to match your review
framework.

## API endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/peers` | Fetch peer list with file status |
| POST | `/api/peers` | Update peers.json (status changes) |
| GET | `/api/file/:slug/evidence` | Fetch evidence markdown |
| GET | `/api/file/:slug/analysis` | Fetch analysis markdown |
| GET | `/api/file/:slug/draft` | Fetch draft markdown |
| POST | `/api/save-draft` | Save draft + update peer status |

### Server implementation (Node.js, no framework)

```js
const http = require('http')
const fs = require('fs').promises
const path = require('path')

const DRAFTS_DIR = path.join(__dirname, 'drafts')
const PEERS_FILE = path.join(__dirname, 'peers.json')

function slugify(name) {
  return name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '')
}

const server = http.createServer(async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*')
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type')

  if (req.method === 'OPTIONS') { res.writeHead(204); res.end(); return }

  const url = new URL(req.url, `http://${req.headers.host}`)

  // GET /api/peers -- list peers with file status
  if (url.pathname === '/api/peers' && req.method === 'GET') {
    const data = JSON.parse(await fs.readFile(PEERS_FILE, 'utf-8'))
    const peers = await Promise.all(data.peers.map(async (p) => {
      const slug = slugify(p.name)
      const exists = async (suffix) => {
        try { await fs.access(path.join(DRAFTS_DIR, `${slug}${suffix}`)); return true }
        catch { return false }
      }
      return {
        ...p, slug,
        files: {
          hasEvidence: await exists('-evidence.md'),
          hasAnalysis: await exists('-analysis.md'),
          hasDraft: await exists('.md'),
        }
      }
    }))
    res.writeHead(200, { 'Content-Type': 'application/json' })
    res.end(JSON.stringify({ peers }))
    return
  }

  // GET /api/file/:slug/:type -- fetch evidence/analysis/draft
  const fileMatch = url.pathname.match(/^\/api\/file\/([^/]+)\/(evidence|analysis|draft)$/)
  if (fileMatch && req.method === 'GET') {
    const [, slug, type] = fileMatch
    const suffix = type === 'draft' ? '.md' : `-${type}.md`
    try {
      const content = await fs.readFile(path.join(DRAFTS_DIR, `${slug}${suffix}`), 'utf-8')
      res.writeHead(200, { 'Content-Type': 'text/plain' })
      res.end(content)
    } catch {
      res.writeHead(404); res.end('Not found')
    }
    return
  }

  // POST /api/save-draft -- save draft + update status
  if (url.pathname === '/api/save-draft' && req.method === 'POST') {
    const body = await readBody(req)
    const { peerName, content } = JSON.parse(body)
    const slug = slugify(peerName)
    const filepath = path.join(DRAFTS_DIR, `${slug}.md`)

    // Backup previous version
    try {
      const prev = await fs.readFile(filepath, 'utf-8')
      await fs.writeFile(path.join(DRAFTS_DIR, `${slug}.prev.md`), prev)
    } catch { /* no previous draft */ }

    // Write new draft
    const header = `# Feedback Draft: ${peerName}\n\nSaved: ${new Date().toISOString()}\n\n---\n\n`
    await fs.writeFile(filepath, header + content)

    // Update peer status to "done"
    const data = JSON.parse(await fs.readFile(PEERS_FILE, 'utf-8'))
    const peer = data.peers.find(p => slugify(p.name) === slug)
    if (peer) peer.status = 'done'
    await fs.writeFile(PEERS_FILE, JSON.stringify(data, null, 2))

    res.writeHead(200, { 'Content-Type': 'application/json' })
    res.end(JSON.stringify({ ok: true, path: filepath }))
    return
  }

  res.writeHead(404); res.end('Not found')
})

server.listen(3847, '127.0.0.1')
```

## UI layout

### Dashboard screen

- **Header:** Tool title, review cycle name, stats (total / done / pending)
- **Progress bar:** Filled width = done peers / total peers
- **Peer cards** grouped by tier:
  - Each tier shows a label, depth descriptor, and completion ratio
  - Cards in a responsive grid (minmax 200px)
  - Each card shows: initials avatar, name, role, status badge
  - File indicator chips: Evidence / Analysis / Draft (appear when files exist)
  - Green background when done, amber when in progress
- **Auto-refresh:** Poll `/api/peers` every 5 seconds for live updates
  (allows Claude to write evidence files while you have the dashboard open)

### Session view (per peer)

Opens when you click a peer card. Four vertically stacked panels:

1. **Evidence panel** -- read-only, monospace, scrollable. Shows the raw
   evidence pulled from meetings/email/chat.

2. **Pre-analysis panel** -- read-only. Shows Claude's synthesis with
   themes, strengths, growth areas, and watch-outs.

3. **Feedback form** -- five cards, one per question. This is where you write.
   Each card has:
   - Question label with the full prompt text
   - Rich text area (click to edit, blur to display)
   - Per-field "Copy" button
   - Supports `**bold**` markdown in display mode

4. **Action bar** -- Save All, Copy All, Reload from Disk

### Rich text field

The editing component toggles between display and edit mode:
- **Display mode:** Renders content with `**bold**` converted to `<strong>`
- **Edit mode:** Plain textarea with auto-height (grows to fit content)
- Click to enter edit mode, blur to return to display
- No auto-save; changes persist in React state until "Save All"

### Clipboard copy (rich format)

```js
// Copy as both HTML and plain text for pasting into HR systems
navigator.clipboard.write([
  new ClipboardItem({
    'text/html': new Blob([html], { type: 'text/html' }),
    'text/plain': new Blob([plain], { type: 'text/plain' }),
  })
])
```

This preserves bold formatting when pasting into Workday, BambooHR,
or similar systems.

## Evidence gathering (the Claude integration)

The dashboard itself does not generate evidence or feedback. It relies on
a Claude Code slash command that:

1. **Pulls evidence from connected sources:**
   - Meeting transcripts (Granola MCP) -- queries all meetings involving the peer
   - Email threads (Gmail MCP) -- searches for threads with or about the peer
   - Chat messages (Slack/GChat MCP) -- pulls DM history and shared channels

2. **Writes structured evidence** to `drafts/{slug}-evidence.md`

3. **Generates pre-analysis** synthesising themes, strengths, growth areas,
   and bias watch-outs. Writes to `drafts/{slug}-analysis.md`

4. **Updates peer status** to `in_progress` in peers.json

The slash command uses dual search patterns (participant filter + name query)
to maximise coverage, since meeting metadata is often incomplete.

### Building the slash command

Create a command file (e.g. `commands/feedback.md`) that:

1. Accepts a peer name as argument
2. Reads peers.json for context (role, tier, relationship, focus area)
3. Searches all connected data sources for interactions with that peer
4. Structures findings chronologically with specific quotes and moments
5. Generates a pre-analysis with bias watch-outs
6. Writes both files to the drafts directory
7. Updates peer status

The quality of the final feedback depends entirely on the evidence pull.
Invest time here. Use wide date ranges, search by both email and name,
and pull full transcripts for key meetings rather than relying on summaries.

## Draft parsing

The parser splits drafts on `## Q\d:` headers:

```js
function parseDraftToFields(md) {
  const fields = { q1: '', q2: '', q3: '', q4: '', q5: '' }
  const sections = md.split(/^## Q(\d):/m)
  for (let i = 1; i < sections.length; i += 2) {
    const num = sections[i]
    const content = (sections[i + 1] || '')
      .replace(/^[^\n]*\n\n/, '')   // Remove header line
      .replace(/\n---\n[\s\S]*$/, '') // Remove footer
      .trim()
    if (num >= 1 && num <= 5) fields[`q${num}`] = content
  }
  return fields
}
```

This is defensive -- tolerates variations in markdown structure and handles
missing sections gracefully. The `## Q1:` through `## Q5:` contract is the
only thing the parser requires.

## Customisation

### Changing the questions

The five questions are defined in a constant array. Replace them with
whatever your review framework uses:

```js
const FEEDBACK_QUESTIONS = [
  { id: 'q1', label: 'Focus Area', prompt: 'What was this person focused on?' },
  { id: 'q2', label: 'Accomplishments', prompt: 'What did they accomplish?' },
  { id: 'q3', label: 'Strengths', prompt: 'What are their key strengths?' },
  { id: 'q4', label: 'Growth Areas', prompt: 'Where could they grow?' },
  { id: 'q5', label: 'Additional', prompt: 'Anything else to share?' },
]
```

### Changing the tiers

Tiers map to collaboration depth. Rename them to fit your context:
- "Team" instead of "Org"
- "Cross-functional" instead of "Heavy"
- "Occasional" instead of "Light"

### Adding/removing data sources

The evidence pull is in the slash command, not the dashboard. Add or
remove sources (Slack, Linear, Notion) by modifying the command file.

## Building it

1. **Create peers.json** with your list of reviewees
2. **Create the drafts/ directory**
3. **Build the Node API** (5 endpoints, ~100 lines, no dependencies)
4. **Build the React app** with Vite:
   - Dashboard view with peer cards grouped by tier
   - Session view with evidence + analysis + 5-field editor
   - Rich text fields with per-field copy
5. **Configure Vite proxy** to route `/api/*` to the Node server
6. **Build the evidence slash command** for your data sources
7. **Run both servers** (`npm run server` + `npm run dev`)

The whole tool is intentionally simple -- a single React component file,
a minimal Node server, and markdown files on disk. No auth, no database,
no build complexity. It's a power tool for a specific job, not a platform.
