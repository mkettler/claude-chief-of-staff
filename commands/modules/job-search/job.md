# /job -- Job Tracker

## Description
Track job opportunities from discovery through application. Accepts a URL or
pasted listing text, extracts structured details, and writes to the pipeline.
Also supports status updates for existing entries.

## Arguments
- `[URL or pasted text]` -- New job listing to process
- `update [company]` -- Update status of an existing entry
- (no argument) -- Show current pipeline summary

## Instructions

### Mode: New Listing

When a URL or pasted job listing text is provided:

#### Step 1: Extract Details

If a URL is provided, fetch the page content with WebFetch. If raw text is
pasted, parse it directly.

Extract and confirm these fields:
- **Company** -- organisation name
- **Role** -- exact title from the listing
- **Location** -- city/country, remote, or hybrid
- **Seniority** -- Director, VP, Head of, Senior, etc.
- **URL** -- listing URL if available
- **Deadline** -- application deadline if stated, otherwise "not stated"

Present the extracted fields for confirmation before proceeding.

#### Step 2: Fit Note

Ask:

> Quick fit note? One line on why this is interesting or how it maps to your
> background. Or I can draft one based on your profile.

If a draft is requested, generate a 1-2 sentence fit note referencing the
profile from my-profile.md. Keep it honest. If the fit is weak, say so.

#### Step 3: Write Entry

After confirmation, append to `~/.claude/jobs.md` using this exact format:

```
| [YYYY-MM-DD] | [Company] | [Role] | [Location] | [Seniority] | [URL or "n/a"] | [Deadline or "not stated"] | [Fit note] | considering |
```

Confirm the write.

#### Step 4: Update goals.yaml

Count non-closed entries in `~/.claude/jobs.md` (statuses: considering, active,
applied, interviewing, offer). Update the relevant key result in goals.yaml.

### Mode: Update Status

When triggered with `update [company]`:

1. Read `~/.claude/jobs.md`
2. Find the matching entry (fuzzy match on company name is fine)
3. Ask for the new status. Valid statuses:
   - **considering** -- on the radar, not yet acting
   - **active** -- actively pursuing
   - **applied** -- application submitted, waiting
   - **interviewing** -- in active interview process
   - **passed** -- decided not to pursue
   - **rejected** -- they said no
   - **offer** -- received an offer
4. Update the status field in the table row
5. Update goals.yaml with recount

### Mode: Pipeline Summary

When triggered with no arguments:

```
JOB PIPELINE ([total] tracked)

ACTIVE / INTERVIEWING
- [Role] at [Company] ([Location]) -- added [date], status: [status]

CONSIDERING
- [Role] at [Company] ([Location]) -- added [date]

APPLIED (waiting)
- [Role] at [Company] ([Location]) -- applied [date]

CLOSED (passed/rejected)
- [Role] at [Company] -- [status]
```

## Guidelines

- Don't oversell fit. If a role is a stretch, say "stretch" in the fit note.
- Default status is always "considering" for new entries.
- When extracting from URLs, if the page can't be fetched, ask for pasted text instead.
- Keep the table in jobs.md append-only. Don't reorder existing rows.
- If a role is clearly wrong level, flag it before writing.
