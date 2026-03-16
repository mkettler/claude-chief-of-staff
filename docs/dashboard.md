# Building a Dashboard

The Chief of Staff system works entirely in the terminal. But the file-based
data layer (`~/.claude/`) makes it straightforward to build a visual dashboard
on top of it. This doc describes the architecture of a companion dashboard
and how to build your own.

## The idea

A Next.js app that reads and writes the same YAML and markdown files that
Claude Code uses. No database, no auth, no sync layer. The filesystem IS
the database. Both the terminal system and the dashboard operate on the
same files, so changes in one are immediately visible in the other.

## What the dashboard shows

### Home (at-a-glance)

Six widgets on a grid:

- **Top 3** -- today's priorities pulled from the latest daily log
- **Pipeline summary** -- job counts by status (if job-search module active)
- **Goal progress** -- key results with progress bars from goals.yaml
- **Network pulse** -- contact staleness summary from contacts/
- **Challenge** -- the current blocker from the morning briefing
- **One good thing** -- extracted from the most recent /eod log

### Tasks (4-tab view)

This is the most powerful page. Four tabs that separate ownership:

| Tab | What it shows | Source |
|-----|---------------|--------|
| **My tasks** | Tasks where `delegate_to_claude: false` | my-tasks.yaml |
| **Claude's queue** | Tasks where `delegate_to_claude: true`, not complete | my-tasks.yaml |
| **Proposals for review** | Pending/stuck proposal YAML files | proposals/*.yaml |
| **Recent** | Recently completed tasks | my-tasks.yaml |

The tasks tab also includes a **brain dump textarea** at the top. Type
multiple items (one per line), optionally check "Delegate to Claude", and
they become tasks instantly. Long items get split into a headline title
and a description field.

**Proposal review cards** show:
- Task title and execution path (A: done, B: autonomous, C: needs terminal)
- Summary of work done
- Deliverables with file paths
- Actions: approve, reject, defer, revise (with notes)

### Pipeline (Kanban)

A drag-and-drop board with columns for each job status:
Considering -- Active -- Applied -- Interviewing -- Offered

Each card shows company, role, location, deadline, and fit note.
Add-job modal for quick entry.

Source: `jobs.md` (markdown table)

### Network (split view)

Left sidebar lists contacts grouped by staleness (needs attention /
approaching stale / healthy). Right panel shows the full contact detail:
role, company, interaction history, career arc, next action.

Staleness is auto-calculated from the most recent interaction date in
each contact file using the same thresholds as /network (14/30/60 days).

Source: `contacts/*.md` (markdown with header tables)

### Briefing (archive + live runner)

Date picker sidebar showing all daily logs. Select a date to read the
full briefing. Sections parsed from markdown headers (morning, midday, eod).

Optional: a "Run /gm" button that executes `claude -p "Run /gm"` via an
API route and streams the output back using Server-Sent Events (SSE).

Source: `logs/daily/*.md`

### Habits (optional)

Calendar grid for daily habit tracking. Monthly markdown files with
check-in entries. Not part of the core CoS system but easy to add.

## Architecture

```
Browser (React)
    |
    | fetch / SSE
    |
Next.js API Routes (Node.js)
    |
    | fs.readFile / fs.writeFile
    |
~/.claude/ filesystem
    |
    | (same files)
    |
Claude Code (terminal)
```

### Tech stack

- **Next.js** (App Router) -- framework
- **React** -- UI
- **Tailwind CSS** -- styling
- **Framer Motion** -- animations (optional, nice for page transitions)
- **js-yaml** -- parse/write YAML files (tasks, goals, proposals)
- **gray-matter** -- parse markdown frontmatter (contacts)
- **TypeScript** -- type safety across the data layer

### Key config

In `next.config.ts`, mark filesystem packages as server-external so they
work in API routes:

```ts
const nextConfig = {
  serverExternalPackages: ['js-yaml', 'gray-matter'],
}
```

## API routes

Every data domain gets a pair of routes: list + detail/update.

### Tasks

```
GET  /api/tasks          -- read my-tasks.yaml, return Task[]
POST /api/tasks          -- append new task to my-tasks.yaml
PATCH /api/tasks/[id]    -- update single task by ID
```

**Reading tasks:**
```ts
import yaml from 'js-yaml'
import { readFile } from 'fs/promises'

const COS_DIR = process.env.HOME + '/.claude'

export async function GET() {
  const raw = await readFile(`${COS_DIR}/my-tasks.yaml`, 'utf-8')
  const data = yaml.load(raw) as { tasks: Task[] }
  return Response.json(data.tasks || [])
}
```

**Writing tasks** (append):
```ts
export async function POST(req: Request) {
  const body = await req.json()
  const raw = await readFile(`${COS_DIR}/my-tasks.yaml`, 'utf-8')
  const data = yaml.load(raw) as { tasks: Task[] }

  const newTask = {
    id: `task-${String(data.tasks.length + 1).padStart(3, '0')}`,
    title: body.title,
    status: body.delegate_to_claude ? 'delegated' : 'pending',
    priority: body.priority || 3,
    created: new Date().toISOString().split('T')[0],
    ...body,
  }

  data.tasks.push(newTask)
  await writeFile(`${COS_DIR}/my-tasks.yaml`, yaml.dump(data))
  return Response.json(newTask)
}
```

### Proposals

```
GET   /api/proposals         -- read all proposals/*.yaml
PATCH /api/proposals/[id]    -- approve/reject/defer/revise
```

**Decision handling:**
- **Approve (Path A):** Set proposal status to `completed`, task status to `complete`
- **Approve (Path B/C):** Set proposal status to `approved`, task to `proposal_ready`
- **Reject:** Set proposal to `rejected`, revert task to `pending`, clear `delegate_to_claude`
- **Defer:** Set proposal to `deferred`
- **Revise:** Set proposal back to `pending` with `decision: revise` and a `decision_note`

### Goals

```
GET /api/goals    -- read goals.yaml, return structured goal data
```

### Contacts

```
GET /api/contacts         -- read all contacts/*.md, parse frontmatter + tables
GET /api/contacts/[slug]  -- single contact with full content
```

**Parsing contact markdown:**
```ts
import matter from 'gray-matter'

// Parse the header table (| Field | Value |) format
function parseHeaderTable(content: string) {
  const lines = content.split('\n')
  const fields: Record<string, string> = {}
  for (const line of lines) {
    const match = line.match(/\|\s*\*\*(.+?)\*\*\s*\|\s*(.+?)\s*\|/)
    if (match) fields[match[1].toLowerCase()] = match[2]
  }
  return fields
}
```

**Auto-calculating staleness:**
```ts
function getStaleness(daysSinceContact: number, category: string) {
  if (category === 'active-opportunity' && daysSinceContact > 14) return 'stale'
  if (category === 'warm' && daysSinceContact > 30) return 'stale'
  if (category === 'dormant' && daysSinceContact > 60) return 'stale'
  return 'current'
}
```

### Jobs

```
GET   /api/jobs          -- parse jobs.md markdown table
PATCH /api/jobs/[key]    -- update status in table row
```

### Briefing

```
GET /api/briefing          -- latest daily log
GET /api/briefing/[date]   -- specific date
GET /api/briefing?dates=true   -- list all available dates
```

### Brain dump

```
POST /api/brain-dump    -- { text: string, delegate_to_claude?: boolean }
```

Splits multiline text into individual tasks. Each line becomes a task.
Lines longer than ~80 characters get split into a title (first sentence)
and description (full text).

### Command runner (optional)

```
POST /api/commands/run?cmd=gm
```

Spawns `claude -p "Run /gm"` as a child process, streams output back
via Server-Sent Events. The client connects with `EventSource` and
renders output in real-time.

## Data types

Core TypeScript interfaces:

```ts
interface Task {
  id: string                    // "task-001"
  title: string
  description?: string
  status: 'pending' | 'in_progress' | 'blocked' | 'complete'
         | 'delegated' | 'proposal_pending' | 'proposal_ready'
  priority: 1 | 2 | 3 | 4
  due_date?: string             // "2026-03-15"
  goal_alignment?: string
  created: string
  notes?: string
  delegate_to_claude?: boolean
}

interface Proposal {
  proposal_id: string           // "prop-20260315-001"
  task_id: string
  task_title: string
  status: 'pending' | 'stuck' | 'approved' | 'rejected'
         | 'deferred' | 'in_progress' | 'completed'
  execution_path: 'A' | 'B' | 'C'
  summary: string
  deliverables: { path: string; description: string }[]
  decision?: 'approve' | 'reject' | 'defer' | 'revise'
  decision_note?: string
  decided_at?: string
  stuck_reason?: string
}

interface Contact {
  name: string
  slug: string                  // filename without .md
  role?: string
  category: string
  email?: string
  location?: string
  connection?: string
  relevance?: string
  last_interaction?: string
  days_since_contact?: number
  staleness: 'active' | 'warm' | 'dormant' | 'cold'
  content: string               // full markdown
}

interface Goal {
  name: string
  description: string
  key_results: {
    metric: string
    target: string | number
    current: string | number
  }[]
}

interface Job {
  date: string
  company: string
  role: string
  location: string
  seniority: string
  url: string
  deadline: string
  fit_note: string
  status: string
}
```

## UI components

### Card system

A base `Card` component with variants handles all content containers:

```tsx
function Card({ variant = 'default', padding = 'normal', children }) {
  const styles = {
    default: 'bg-surface border border-border',
    glass: 'bg-surface/80 backdrop-blur border border-border',
    glow: 'bg-surface border border-accent/20 shadow-[0_0_15px_rgba(accent,0.1)]',
  }
  // ...
}
```

### Badge system

Colour-coded badges for status, priority, goal alignment, and staleness:

```tsx
function Badge({ label, variant = 'default' }) {
  const colors = {
    default: 'bg-muted text-muted-foreground',
    accent: 'bg-accent/10 text-accent',
    success: 'bg-green-500/10 text-green-400',
    warning: 'bg-yellow-500/10 text-yellow-400',
    error: 'bg-red-500/10 text-red-400',
  }
  // ...
}
```

### Layout

```
ShellLayout
  ├── Sidebar (nav links, theme toggle)
  └── Main content area (max-width ~1200px)
      └── PageTransition (framer-motion)
          └── Page content
```

## Deployment

### Local only

The simplest approach. Run `npm run dev` and access at localhost:3000.
Since the API routes read from `~/.claude/`, the dashboard only works
on the machine where your CoS system lives.

### Vercel (with caveats)

You can deploy to Vercel, but the API routes that read from the filesystem
won't work in production (Vercel is serverless, no persistent filesystem).
Options:
- Use it as a local dashboard only (the natural fit)
- Add a sync layer (git-based, or an API that proxies to your machine)
- Replace filesystem reads with a database (loses the elegance)

The local-only approach is recommended. The whole point is that the
filesystem is the single source of truth.

## Getting started

1. **Scaffold:** `npx create-next-app@latest cos-dashboard --typescript --tailwind --app`
2. **Add deps:** `npm install js-yaml gray-matter framer-motion react-markdown`
3. **Create API routes** following the patterns above
4. **Build pages** starting with the home dashboard and tasks view
5. **Point all file reads** at `process.env.HOME + '/.claude/'`

Start with the tasks page (it's the most useful) and add pages as needed.
The filesystem abstraction layer (`lib/data/tasks.ts`, `lib/data/goals.ts`,
etc.) keeps things clean -- one module per data domain.

## Design notes

- **Dark theme by default.** You're staring at a terminal all day. Match it.
- **Small text (13px body, 11px labels).** Information density matters more than readability at arm's length.
- **Minimal colour.** Use colour for status and staleness, not decoration.
- **No loading spinners.** Data is local filesystem reads -- they're fast. Show skeleton cards if you must.
- **No real-time sync.** The user triggers refreshes. Pull-based, like the terminal system.
