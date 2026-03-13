# /review -- Rapid Task Review

## Description
Swipe through your open tasks one at a time. For each: done, act on it, skip,
or drop. Ends with a brain dump prompt to catch anything the review shook loose.

## Arguments
- (no argument) -- Full review of all open tasks
- `quick` -- Only overdue and due-today tasks

## Instructions

### Step 1: Load and Sort

Read `~/.claude/my-tasks.yaml`. Filter to open tasks only (status: pending or
in_progress). Exclude completed tasks.

Sort order (most urgent first):
1. Overdue (oldest first)
2. Due today
3. Priority 1
4. Priority 2
5. Priority 3
6. Priority 4
7. No due date

If argument is `quick`, only include overdue and due-today tasks.

Count total open tasks. If zero: "Task list is clear. Nice work." and exit.

### Step 2: Show Full List Overview

Before cycling, show the entire list as a scannable overview:

```
[X] open tasks:

 #  | Flag     | Title                                          | Due    | Goal
----|----------|------------------------------------------------|--------|------
 1  | !! LATE  | [title truncated to ~45 chars]                 | Feb 20 | [goal]
 2  | ! TODAY  | [title]                                        | Feb 21 | [goal]
 3  |          | [title]                                        | Feb 22 | [goal]
...

Ready to cycle through? Starting from the top.
```

### Step 3: Cycle Through Tasks

For each task, present a compact card and ask for a decision.

**Card format:**

```
[position/total]  P[priority] [urgency_flag]

[title]
Due: [date or "none"] | Goal: [goal_alignment]
> [first line of notes, or description truncated to ~80 chars]
```

**Options:**
- **Done** -- "Mark complete and move on"
- **Act on it** -- "Pause review, work on this now"
- **Skip** -- "Next task"
- **Drop** -- "Delete this task (stale or no longer relevant)"

### Step 4: Process Each Decision

**Done:** Update task status to "complete", show confirmation, next card.
**Act on it:** Pause review, ask what to do (update, execute, discuss). After, ask "Resume review?"
**Skip:** Move to next task immediately. No commentary.
**Drop:** Remove task, show confirmation, next card.

### Step 5: Summary

```
REVIEW COMPLETE

Done:    [X] marked complete
Acted:   [X]
Skipped: [X]
Dropped: [X] removed

[Y] tasks remaining.
```

### Step 6: Brain Dump

Always end with:

```
Anything else rattling around? Sometimes reviewing tasks shakes
other things loose. Type it out or hit enter to finish.
```

If input is provided, process through /capture flow. If not, exit clean.

### Guidelines

- **Speed is everything.** One task, one decision, move on.
- **Don't editorialize on skips.** No "are you sure?" or "this one's been sitting."
- **Keep cards tight.** Title + due + goal + one line of context.
- **Batch writes.** Update my-tasks.yaml after each done/drop, not at the end.
- **The brain dump at the end is not optional.** Reviews surface adjacent thoughts.
