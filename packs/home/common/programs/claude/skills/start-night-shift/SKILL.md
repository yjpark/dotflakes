---
name: start-night-shift
description: Autonomous overnight work loop. Use when the user says "start night shift", "night shift", "work overnight", "work while I sleep", or otherwise indicates they want the agent to autonomously work through available tasks without supervision. Requires beans (issue tracker) to be configured in the project.
---

# Night Shift — Autonomous Task Loop

The user is stepping away and will not be available for questions. Work autonomously through all ready tasks until none remain or you approach the usage limit.

## Ground Rules

- **Never ask for confirmation.** The user is away. Make decisions confidently.
- **Follow all project conventions.** CLAUDE.md defines how development works in this project — follow it exactly as you would in an interactive session. The skill defines *what* to work on and *when to stop*, not *how to develop*.
- **Track everything with beans.** Update bean status and check off todo items as you go. Include bean files in commits.

## Resolving Ambiguity

When a spec is unclear or you face a non-trivial design decision:

1. Check related beans, parent beans, design docs, and existing code for context
2. Brainstorm approaches — consider spawning a subagent to get a second perspective if the decision is significant
3. If you reach a confident decision that aligns with the project's existing patterns and design principles, document your reasoning in the bean and proceed
4. If you genuinely cannot determine the right approach, mark the bean as `draft`, add a `## Blocked` note explaining the ambiguity, and move to the next task

The threshold: would a competent team member make this call without escalating? If yes, proceed. If it's the kind of decision that would warrant a team discussion, don't guess — mark it blocked.

## Task Selection

Pick the next task from `beans list --ready --json` using this priority order:

1. **Priority level**: critical > high > normal > low > deferred
2. **Type**: bug > task > feature (bugs first — they tend to block others)
3. **Architectural layer**: data model / API / core library before CLI / frontend / UI (foundational changes first, so downstream tasks can build on them)
4. **Leverage**: prefer tasks whose completion would unblock other tasks (check `blocking` relationships)

## The Loop

Repeat until `beans list --ready` returns nothing or you're approaching the usage limit:

### 1. Pick & Claim

Select the highest-priority task per the ordering above. Read its full spec with `beans show --json <id>`. Mark it in-progress:

```
beans update <id> -s in-progress
```

### 2. Understand the Spec

Read the bean's body carefully. If it references other beans, design docs, or files — read those too. Build a clear picture of what "done" looks like, including acceptance criteria if listed.

### 3. Plan

Think through the implementation:
- What files need to change
- What new types/functions are needed
- What tests will verify correctness
- Edge cases from the spec

Append a `## Plan` section to the bean body. This is a lightweight checkpoint — not a separate repo commit.

### 4. Implement

Follow the project's development workflow as defined in CLAUDE.md. The project conventions dictate how to write code, tests, and commits — follow them as if the user were watching.

### 5. Review

Spawn a subagent to review the changes with fresh eyes:

> Review the changes in the last 1-2 commits on the current branch. Look for: logic errors, missed edge cases, violations of existing code patterns, missing test coverage, and any issues a careful reviewer would catch. Be specific — point to exact lines. Only flag real issues, not style nitpicks.

If a subagent can't be spawned, do a self-review: re-read the full diff with critical eyes.

Fix any real issues found, verify the project's acceptance criteria still pass, and commit the fixes.

### 6. Complete the Bean

Once all todo items are checked off and acceptance criteria are met:

```
beans update <id> -s completed --body-append "## Summary of Changes\n\n<what was done, key decisions made>"
```

Include the final bean update in a commit.

### 7. Next Task

Return to step 1.

## End of Shift

When there are no more ready tasks or you're approaching the usage limit, leave a summary:

- Tasks completed (bean IDs and titles)
- Tasks skipped or blocked (and why)
- Any observations, risks, or suggested follow-ups
