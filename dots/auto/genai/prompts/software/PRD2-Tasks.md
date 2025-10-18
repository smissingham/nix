# PRD: Task Breakdown

> **USER COMMAND** - Break requirements into executable tasks
> 
> **Agent:** Read Refined Requirements section, decompose into discrete tasks with dependencies.
>
> **CRITICAL:** Write to `agents/tasks/wip/[task].md` incrementally. Save after defining each task to support recovery.

## Your Task

Read Refined Requirements section from task file and create:
1. Discrete implementation tasks (assign sequential subtask IDs)
2. Dependency mapping

**Task ID Format:** XXX.YY where XXX is the PRD number from the file, YY starts at 01 for first subtask.
- Example: If file is TASK-005.00, subtasks are TASK-005.01, TASK-005.02, etc.
- If only one task needed, can stay at TASK-005.00

**CRITICAL:** Save file after defining each task. This enables recovery if interrupted.

## Write Incrementally to Task Breakdown Section

```markdown
## Task Breakdown

### TASK-XXX.01: [Name]
**Task ID:** TASK-XXX.01  (Agent assigns)
**Status:** 🔵 NOT_STARTED
**Dependencies:** None
**Blocks:** TASK-XXX.02

**What to do:**
[What needs to be done and why]

**Files:**
- `path/to/file` - [changes needed]

**Success:**
- [ ] [Observable outcome]
- [ ] Build/lint pass
- [ ] Tests pass (if framework exists)

**Testing:**
- Check test framework exists first
- If YES: [Tests to write]
- If NO: [Manual steps - agent uses agents/sandbox/, removes all artifacts after]

**Notes:**
[Context or decisions]
[SAVE FILE]

### TASK-XXX.02: [Name]
**Task ID:** TASK-XXX.02  (Agent assigns)
[Same structure]
[SAVE FILE]

[Continue for all tasks...]
```

## Testing Guidance

**Always check for test framework first:**
```bash
# Look for: tests/ dir, *_test.* files, test deps in package.json/Cargo.toml
```

- **If exists**: Specify unit/integration tests
- **If not**: Specify manual verification in agents/sandbox/ + cleanup protocol

## When Complete

1. All tasks defined and saved
2. Set status: `TASKS_COMPLETE`
3. Present summary:
   - Task count
   - Key dependencies
4. Ask for adjustments
5. **STOP** - User will explicitly invoke Execution stage when ready
