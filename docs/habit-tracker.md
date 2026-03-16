# Building a Habit Tracker

An optional module for the dashboard that tracks daily habits with a radial
sunburst visualisation. Months as circles, habits as concentric rings, days
as segments. Patterns become visible at a glance.

## The idea

Track 3-8 daily habits with a three-state model (done / missed / unrecorded)
and optional daily observations. At month-end, run a reflection ritual that
generates stats, collects your observations, and feeds them to Claude for
analysis.

## Data storage

**Location:** `~/.claude/habits/`
**Format:** JSON files, one per month, named `YYYY-MM.json`

### MonthDocument

```typescript
interface MonthDocument {
  id: string                            // "2026-03"
  year: number                          // 2026
  month: number                         // 3 (1-indexed)
  startDay: number                      // Day of month tracking began
  habits: Habit[]                       // 3-8 habit definitions
  entries: Record<string, DayEntry>     // Keyed by day number ("1", "15", etc)
  analysis: string | null               // Claude analysis from month-end ritual
  status: 'active' | 'completed'
}

interface Habit {
  id: string          // "h1", "h2", etc
  label: string       // "Exercise 30 min" or "Read 20 pages"
  position: number    // 0-7, determines ring position (innermost first)
}

interface DayEntry {
  habits: Record<string, boolean | null>   // { h1: true, h2: false, h3: null }
  observation: string                       // Free-text daily note
}
```

**Three-state tracking** is the key insight. Unlike binary checkboxes:
- `true` -- done
- `false` -- deliberately marked as missed
- `null` -- unrecorded (didn't get to it, forgot, or not applicable today)

This distinction matters for honest reflection. "I missed 5 days" is
different from "I forgot to track 5 days."

## API routes

```
GET    /api/habits              -- list all month IDs
GET    /api/habits?id=2026-03   -- fetch single MonthDocument
POST   /api/habits              -- create new month (body: MonthDocument)
PUT    /api/habits/update       -- full month replacement (for saving analysis)
PATCH  /api/habits/update       -- partial day update (query: monthId, day)
```

### Partial day update (most common operation)

```ts
// PATCH /api/habits/update?monthId=2026-03&day=15
// Body: { habits: { h1: true, h3: false }, observation: "Low energy today" }

export async function PATCH(req: Request) {
  const { searchParams } = new URL(req.url)
  const monthId = searchParams.get('monthId')
  const day = searchParams.get('day')
  const patch = await req.json()

  const month = await getMonth(monthId)
  const entry = month.entries[day] || { habits: {}, observation: '' }

  // Merge patch into existing entry
  if (patch.habits) entry.habits = { ...entry.habits, ...patch.habits }
  if (patch.observation !== undefined) entry.observation = patch.observation

  month.entries[day] = entry
  await updateMonth(monthId, month)

  return Response.json(entry)
}
```

## UI components

### Radial chart (the centrepiece)

An SVG sunburst where:
- Each **ring** is a habit (innermost = first habit)
- Each **segment** is a day of the month
- **Colour** encodes state: green (done), red (missed), grey (unrecorded)
- Today's segment has an accent border
- Selected day has a highlight border

**Geometry:**

```ts
const CHART_SIZE = 556      // px (500 + padding)
const CX = 278, CY = 278   // centre
const INNER_RADIUS = 80     // innermost ring starts here
const OUTER_RADIUS = 240    // outermost ring ends here
const RING_GAP = 1          // px between rings

function getRingRadii(habitCount: number) {
  const ringWidth = (OUTER_RADIUS - INNER_RADIUS - (habitCount - 1) * RING_GAP) / habitCount
  return Array.from({ length: habitCount }, (_, i) => ({
    inner: INNER_RADIUS + i * (ringWidth + RING_GAP),
    outer: INNER_RADIUS + i * (ringWidth + RING_GAP) + ringWidth,
  }))
}

function getSegmentAngles(daysInMonth: number) {
  const segmentAngle = 360 / daysInMonth
  return Array.from({ length: daysInMonth }, (_, i) => ({
    start: i * segmentAngle - 90,  // -90 so day 1 is at top
    end: (i + 1) * segmentAngle - 90,
  }))
}
```

Each arc segment is an SVG `<path>` built from polar-to-cartesian conversion:

```ts
function polarToCartesian(cx, cy, radius, angleDeg) {
  const rad = (angleDeg * Math.PI) / 180
  return { x: cx + radius * Math.cos(rad), y: cy + radius * Math.sin(rad) }
}

function describeArc(cx, cy, innerR, outerR, startAngle, endAngle) {
  const outerStart = polarToCartesian(cx, cy, outerR, startAngle)
  const outerEnd = polarToCartesian(cx, cy, outerR, endAngle)
  const innerStart = polarToCartesian(cx, cy, innerR, startAngle)
  const innerEnd = polarToCartesian(cx, cy, innerR, endAngle)
  const largeArc = endAngle - startAngle > 180 ? 1 : 0

  return [
    `M ${outerStart.x} ${outerStart.y}`,
    `A ${outerR} ${outerR} 0 ${largeArc} 1 ${outerEnd.x} ${outerEnd.y}`,
    `L ${innerEnd.x} ${innerEnd.y}`,
    `A ${innerR} ${innerR} 0 ${largeArc} 0 ${innerStart.x} ${innerStart.y}`,
    'Z',
  ].join(' ')
}
```

**Interaction:** Click a segment to select that day (opens detail panel).
Click again to cycle the habit state: done -> missed -> unrecorded -> done.

### Day detail panel

A sidebar that appears when a day is selected:

- List of habits with Y/N toggle buttons
- Observation textarea with 500ms debounce auto-save
- Completion count: "5/7 (71%)"

**Keyboard shortcuts:**
- Arrow left/right: navigate previous/next day
- Escape: deselect day
- 1-8: toggle habit by position number
- O: focus observation textarea

### Month setup

A modal for initialising a new month:
- Year/month/start-day selectors
- Habit list editor (add/remove/reorder, max 8)
- Auto-loads habits from previous month if available

### Month-end ritual

A 5-step wizard that forces reflection:

1. **Review stats** -- completion rates, streaks, best/worst habits
2. **Read observations** -- all daily notes concatenated chronologically
3. **Export prompt** -- generates a structured prompt with stats + observations,
   copies to clipboard for pasting into Claude
4. **Paste analysis** -- text area to paste Claude's analysis back
5. **Confirm** -- saves analysis to MonthDocument, marks month as completed

### Mini radial

A tiny (48-60px) read-only version of the radial chart used in the history
view for showing monthly summaries at a glance.

## Statistics engine

```ts
interface MonthStats {
  activeDays: number
  habitStats: HabitStats[]       // per-habit breakdown
  totalCompleted: number
  totalPossible: number
  overallPct: number
  bestStreak: number             // longest consecutive all-habits-done days
  bestStreakStart: number
  bestStreakEnd: number
  activeStreak: number           // current streak from end
  bestHabit: HabitStats
  worstHabit: HabitStats
}

interface HabitStats {
  id: string
  label: string
  completed: number              // count of true
  missed: number                 // count of false
  unrecorded: number             // count of null
  total: number                  // activeDays
  pct: number                    // completion percentage
}
```

The analysis prompt generator formats these stats as an ASCII table with
progress bars, appends all daily observations, and asks Claude to identify
patterns, correlations, and recommendations.

## Building it

1. **Create `~/.claude/habits/` directory**
2. **Add API routes** (4 endpoints: list, get, create, update/patch)
3. **Build the SVG radial chart** -- this is the hardest part. Start with
   the geometry functions, then render arc segments with colour-coded fills.
4. **Add the detail panel** with habit toggles and observation textarea
5. **Add month setup** and month-end ritual flows
6. **Wire up keyboard shortcuts** for fast daily tracking

The radial chart is what makes this special. A simple grid/calendar view
works too, but the sunburst reveals patterns (weekday vs weekend, habit
correlation, streaks) that are invisible in a list.
