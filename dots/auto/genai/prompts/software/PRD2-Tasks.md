# PRD: Task Breakdown

> **USER COMMAND** - Break requirements into executable task files
> 
> **Agent:** Read Refined Requirements from user's file, create separate task file for each discrete task.
>
> **CRITICAL:** Create one file per task in `agents/tasks/todo/TASK-XXX.YY-brief-name.md`. Save after creating each file to support recovery.

## Your Task

Read Refined Requirements section from the user's requirement file and create:
1. Discrete implementation task files (one file per task)
2. Task ID assignment (check existing TASK-* files, increment from highest)

**Task ID Format:** TASK-XXX.YY where:
- XXX = Next available PRD number (check existing TASK-* files)
- YY = Subtask number starting at 01
- Example: TASK-001.01, TASK-001.02, TASK-002.01, etc.

**File naming:** `agents/tasks/todo/TASK-XXX.YY-brief-description.md`

**CRITICAL:** Create and save each task file individually. This enables recovery if interrupted.

## Create Individual Task Files

For each task, create `agents/tasks/todo/TASK-XXX.YY-brief-name.md`:

```markdown
# TASK-XXX.YY: [Name]

**Task ID:** TASK-XXX.YY
**Status:** 🔵 NOT_STARTED
**Dependencies:** [TASK-XXX.YY, ...] or None
**Blocks:** [TASK-XXX.YY, ...] or None
**Created:** YYYY-MM-DD

---

## What to Do

[What needs to be done and why]

---

## Files

- `path/to/file` - [changes needed]

---

## Success Criteria

- [ ] [Observable outcome]
- [ ] Build/lint pass
- [ ] Tests pass (if framework exists)

---

## Testing

**Check test framework exists first**
- If YES: [Tests to write]
- If NO: [Manual steps - agent uses agents/sandbox/, removes all artifacts after]

---

## Notes

[Context or decisions]

---

## Execution Log

[Orchestrator writes here during execution]
```

**After creating file:** Update requirement file with task reference:
```markdown
---

## Generated Tasks

- `TASK-XXX.01` - [Brief description]
- `TASK-XXX.02` - [Brief description]
```

## Testing Guidance

**Always check for test framework first:**
```bash
# Look for: tests/ dir, *_test.* files, test deps in package.json/Cargo.toml
```

- **If exists**: Specify unit/integration tests
- **If not**: Specify manual verification in agents/sandbox/ + cleanup protocol

## When Complete

1. All task files created in `agents/tasks/todo/`
2. Update requirement file with task list
3. Set requirement file status: `TASKS_COMPLETE`
4. Present summary:
   - Task files created
   - Key dependencies
5. Ask for adjustments
6. **STOP** - User will explicitly invoke Execution stage when ready
