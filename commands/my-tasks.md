# /my-tasks -- Task Management

## Description
Track, prioritise, and execute tasks with goal alignment and structured
accountability. Not a passive list -- an active system that pushes back on
vague intentions and holds you accountable.

## Arguments
- `list` -- Show all active tasks, grouped by urgency
- `add "title" --due YYYY-MM-DD --goal "goal-name"` -- Add a new task
- `complete <task-id>` -- Mark a task as complete
- `execute` -- Work on the highest-priority pending task
- `dump` -- Brain-dump mode. Get it all out, then sort.
- `overdue` -- Show only overdue and at-risk tasks
- (no argument) -- Same as `list`

## Task File
Location: `~/.claude/my-tasks.yaml`

## Instructions

### /my-tasks list

Read `~/.claude/my-tasks.yaml` and present tasks grouped by urgency:

```
TASKS

OVERDUE (action required)
- [task-id] [title] -- due [date] ([X days late]) -- goal: [goal]

DUE TODAY
- [task-id] [title] -- goal: [goal]

THIS WEEK
- [task-id] [title] -- due [date] ([X days]) -- goal: [goal]

BACKLOG
- [task-id] [title] -- due [date] -- goal: [goal]

Summary: [X] active, [Y] overdue, [Z] due this week
```

If there are overdue tasks, flag them and ask:
"Want me to help execute [task], reschedule it, or break it down?"

If a task has been sitting with no progress for 5+ days, call it out.

### /my-tasks add

When adding a task:

1. Generate a unique task ID (format: `task-XXX`)
2. Validate the task is specific enough. Push back on vague tasks:
   - "update profile" -> "Rewrite profile headline to reflect current positioning"
   - "work on project" -> "Draft the architecture doc for the payments integration"
3. Require or suggest:
   - Title (required, must be specific)
   - Due date (required -- always set one, even if approximate)
   - Goal alignment (required -- which goal does this advance?)
   - Priority (must-do today / this week / backlog)
   - Status (not started / in progress / blocked / done)
4. Check `~/.claude/goals.yaml` for alignment. If the task doesn't align with any active goal, flag it.
5. Write to `~/.claude/my-tasks.yaml`
6. Confirm: "Added: [title] -- due [date] -- goal: [goal]"

### /my-tasks complete

1. Find the task by ID
2. Update status to "done" with completion date
3. Confirm: "Done: [title]"
4. If completed before due date: "Nice -- finished [X] days early."
5. If it was overdue: note it without judgement, move on.

### /my-tasks execute

This is where Claude actively helps get work done.

1. Identify the highest-priority actionable task
2. Check calendar to confirm there's time now
3. Present the task and a concrete plan:
   ```
   Ready to work on: [task title]
   Due: [date] | Goal: [goal] | Priority: [priority]

   Plan:
   1. [Step 1]
   2. [Step 2]
   3. [Step 3]

   Shall I proceed?
   ```
4. Execute (draft emails, research, create documents, etc.)
5. Present progress and ask for feedback
6. Don't expand scope. If the task says "draft email," draft the email.

### /my-tasks dump

Brain-dump mode:

1. Tell the user: "Go. List everything that's on your mind. Don't filter, don't prioritise, just dump."
2. Collect everything listed
3. Sort into categories:
   - **Must-do today** -- time-sensitive, blocking something, or high-impact
   - **This week** -- important but not urgent
   - **Backlog** -- good to do eventually
   - **Not a task** -- worries, vague intentions, things to let go of
4. For each item, sharpen it into a specific task with a due date and goal
5. Push back on anything vague
6. Present the sorted list for approval before writing to my-tasks.yaml

### /my-tasks overdue

Quick check for overdue and at-risk tasks:

1. **OVERDUE** -- past due, not done
2. **AT RISK** -- due within 48 hours, not started or blocked
3. **APPROACHING** -- due within 7 days

For each, suggest: execute, reschedule, or break down.

### Guidelines

- Every task must have a due date. No exceptions.
- Push back on vague tasks. Specificity is kindness.
- When executing, be specific about what you're doing and why.
- Don't expand scope beyond the task.
- Celebrate early completions. Positive reinforcement matters.
- If outreach or high-impact tasks keep getting skipped, escalate.
- The dump workflow is not optional -- support it fully.
