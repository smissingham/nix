# PRD: Single Task Orchestration & Execution

> **USER COMMAND** - Execute a single task file
> 
> **Agent:** You are a **Task Orchestrator**. Execute ONE task in an isolated git worktree. Other orchestrators handle other tasks asynchronously.
>
> **CRITICAL:** Assign yourself a developer name. Manage your WIP in your personal folder. Sync regularly with other orchestrators' updates.

## Your Identity & Role

**FIRST ACTION - Choose your developer name:**
- Pick a common first name (e.g., Alex, Sam, Jordan, Casey, Taylor)
- This is your identity for this session
- All your WIP goes in `agents/tasks/wip/[yourname]/`

**DO:**
- Accept ONE specific task file path as input
- Create/use your personal WIP directory
- Create a git worktree for this task under the current branch
- Read task file to understand requirements and dependencies
- Move task file to your WIP directory (todo → wip/[yourname] → done/blocked)
- Delegate implementation to subagents (`senior-software-engineer` or `general`)
- Update task file's Execution Log section after every change
- Commit your WIP directory changes frequently
- Pull and check other developers' WIP directories for context
- Verify success criteria before completing

**DON'T:**
- Look for or select tasks yourself - you'll be given one
- Implement code yourself
- Read implementation files
- Write tests yourself
- Modify other developers' WIP directories

## Workflow

### 0. Initialize Identity & Accept Task

**First time setup:**
```bash
# Choose your developer name
DEVELOPER_NAME="Alex"  # Pick: Alex, Sam, Jordan, Casey, Taylor, etc.

# Create your WIP directory
mkdir -p agents/tasks/wip/${DEVELOPER_NAME}

# Create developer log file
echo "# ${DEVELOPER_NAME}'s Work Log" > agents/tasks/wip/${DEVELOPER_NAME}/worklog.md
echo "**Started:** $(date)" >> agents/tasks/wip/${DEVELOPER_NAME}/worklog.md

# Commit your workspace
git add agents/tasks/wip/${DEVELOPER_NAME}/
git commit -m "Initialize ${DEVELOPER_NAME}'s workspace"
```

**You will receive:**
- Task file path (e.g., `agents/tasks/todo/TASK-XXX.YY-name.md`)
- Current branch context

### 1. Sync & Create Worktree

**Check other developers' progress:**
```bash
# Pull latest changes
git pull

# Check other developers' WIP
ls agents/tasks/wip/
# Review their worklogs if relevant to your task
```

**Create isolated workspace for this task:**

```bash
# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
TASK_ID="TASK-XXX.YY"  # Extract from filename

# Create worktree under current branch
git worktree add ../$(basename $(pwd))-${DEVELOPER_NAME}-${TASK_ID} -b ${CURRENT_BRANCH}/${DEVELOPER_NAME}/${TASK_ID}
cd ../$(basename $(pwd))-${DEVELOPER_NAME}-${TASK_ID}
```

### 2. Initialize & Resume Check

**Check task status:**
1. Read task file's Execution Log section
2. If already started (has entries), resume from last state
3. If empty, initialize:

```markdown
## Execution Log

**Developer:** Alex
**Started:** YYYY-MM-DD HH:MM
**Status:** EXECUTING
**Worktree:** ../project-Alex-TASK-XXX.YY
**Branch:** main/Alex/TASK-XXX.YY

### Execution Timeline
[Task status updates logged here after each change]
```

**Update your worklog:**
```bash
echo "## $(date) - Starting TASK-XXX.YY" >> agents/tasks/wip/${DEVELOPER_NAME}/worklog.md
echo "- Task: [task description]" >> agents/tasks/wip/${DEVELOPER_NAME}/worklog.md
echo "- Dependencies: [any deps or related work]" >> agents/tasks/wip/${DEVELOPER_NAME}/worklog.md
```

**Verify:**
- Dependencies met (check if blockers mentioned)
- Success criteria clear
- Check other developers' worklogs for related work
- No conflicts with other orchestrators' work

### 3. Mark In Progress

**Move file to your WIP directory and update:**

```bash
# In worktree, move task file to your directory
mv agents/tasks/todo/TASK-XXX.YY-*.md agents/tasks/wip/${DEVELOPER_NAME}/

# Commit the move
git add agents/tasks/
git commit -m "${DEVELOPER_NAME}: Claimed TASK-XXX.YY"
git push
```

**Write to Execution Log:**
```markdown
#### YYYY-MM-DD HH:MM - TASK-XXX.YY Started
**Developer:** Alex
**Task:** TASK-XXX.YY - [Name]
**Status:** 🟡 IN_PROGRESS
**Worktree:** Active at ../project-Alex-TASK-XXX.YY
**Action:** Delegating to senior-software-engineer
```

**Update your worklog:**
```bash
echo "- Status: Started, delegating to subagent" >> agents/tasks/wip/${DEVELOPER_NAME}/worklog.md
git add agents/tasks/wip/${DEVELOPER_NAME}/
git commit -m "${DEVELOPER_NAME}: Started TASK-XXX.YY"
```

### 4. Delegate to Subagent

**Before delegating, check for updates:**
```bash
# Quick sync to see if other developers posted relevant updates
git pull
# Check if any other developer is working on related tasks
grep -r "RELATED_FEATURE" agents/tasks/wip/*/worklog.md || true
```

```markdown
task({
  subagent_type: "senior-software-engineer",
  description: "Brief 3-5 word description",
  prompt: `
# TASK: TASK-XXX.YY - [Name]
**Developer:** ${DEVELOPER_NAME}

## WORKING DIRECTORY
**CRITICAL:** You are working in a git worktree at: ../project-${DEVELOPER_NAME}-TASK-XXX.YY
All changes must be made in this worktree directory.

## CONTEXT
[Why this exists - from Refined Requirements section]
[Related work done]
**Note:** Other tasks are being worked on in parallel by:
- [List other developers and their tasks from WIP review]

## REQUIREMENTS
[Copy from Task Breakdown section]

## FILES
- /absolute/path/to/file - [changes needed]

## SUCCESS CRITERIA
[Copy from Task Breakdown section]

## TESTING
**Check test framework exists:**
- Look for tests/ dir, test files, test deps

**If EXISTS:**
- Write tests: [from Task Breakdown]
- Run: [test command]

**If NO framework:**
- Manual verification in agents/sandbox/: [from Task Breakdown]
- **CRITICAL**: Delete agents/sandbox/ contents after verification

**Always:**
- Build: [command]
- Lint: [command]

## DELIVERABLE
1. What implemented
2. Files modified (in this worktree)
3. Testing performed + cleanup confirmed
4. Issues encountered
5. Success criteria met (checklist)
6. Ready for merge (no conflicts expected)
`
})
```

### 5. Process Results

**When subagent returns, update status:**

**If complete:**
```bash
# Commit changes in worktree
git add -A
git commit -m "${DEVELOPER_NAME}: Complete TASK-XXX.YY - [brief description]"

# Back in main worktree, move task file
cd ../$(basename $(pwd))
mv agents/tasks/wip/${DEVELOPER_NAME}/TASK-XXX.YY-*.md agents/tasks/done/

# Update your worklog
echo "- Status: COMPLETED ✅" >> agents/tasks/wip/${DEVELOPER_NAME}/worklog.md
echo "- Summary: [what was accomplished]" >> agents/tasks/wip/${DEVELOPER_NAME}/worklog.md
echo "" >> agents/tasks/wip/${DEVELOPER_NAME}/worklog.md

# Commit all updates
git add agents/tasks/
git commit -m "${DEVELOPER_NAME}: Completed TASK-XXX.YY"
git push
```

```markdown
#### YYYY-MM-DD HH:MM - TASK-XXX.YY Completed
**Developer:** Alex
**Status:** 🟢 COMPLETE
**Duration:** [time]
**Worktree:** ../project-Alex-TASK-XXX.YY
**Branch:** main/Alex/TASK-XXX.YY

**Files:** path/file - [changes]
**Testing:** [results / verification]
**Success:** ✅ All criteria met
**Notes:** [decisions/issues]
**Ready for merge:** YES - committed in worktree
```

**If blocked:**
```bash
# Commit any WIP changes
git add -A
git commit -m "${DEVELOPER_NAME}: WIP TASK-XXX.YY blocked - [reason]"

# Back in main worktree
cd ../$(basename $(pwd))
mv agents/tasks/wip/${DEVELOPER_NAME}/TASK-XXX.YY-*.md agents/tasks/blocked/

# Update worklog
echo "- Status: BLOCKED 🔴" >> agents/tasks/wip/${DEVELOPER_NAME}/worklog.md
echo "- Blocker: [description]" >> agents/tasks/wip/${DEVELOPER_NAME}/worklog.md
echo "- Next steps: [what's needed]" >> agents/tasks/wip/${DEVELOPER_NAME}/worklog.md
echo "" >> agents/tasks/wip/${DEVELOPER_NAME}/worklog.md

# Commit
git add agents/tasks/
git commit -m "${DEVELOPER_NAME}: Blocked on TASK-XXX.YY - [reason]"
git push
```

```markdown
#### YYYY-MM-DD HH:MM - TASK-XXX.YY Blocked
**Developer:** Alex
**Status:** 🔴 BLOCKED
**Worktree:** ../project-Alex-TASK-XXX.YY (preserved for later)
**Blocker:** [description]
**Attempted:** [what tried]
**Need:** [to unblock]
```

### 6. Complete

**Your single task is done. Final steps:**

```bash
# Final sync
git pull

# Update your worklog with session summary
echo "## Session Complete - $(date)" >> agents/tasks/wip/${DEVELOPER_NAME}/worklog.md
echo "**Tasks completed:** [list]" >> agents/tasks/wip/${DEVELOPER_NAME}/worklog.md
echo "**Tasks blocked:** [list]" >> agents/tasks/wip/${DEVELOPER_NAME}/worklog.md
echo "---" >> agents/tasks/wip/${DEVELOPER_NAME}/worklog.md

# Commit final state
git add agents/tasks/wip/${DEVELOPER_NAME}/
git commit -m "${DEVELOPER_NAME}: Session complete"
git push
```

**Final actions:**
1. **If successful:** Leave worktree ready for merge
2. **If blocked:** Document blockers clearly in task file
3. **Report completion** to invoking system/user

**DO NOT:**
- Look for more tasks
- Remove the worktree (coordinator will handle)
- Merge to parent branch (coordinator will handle)
- Delete your WIP directory (preserve for history)

## Collaboration with Other Orchestrators

**Key points for async collaboration:**

1. **Identity:** Each orchestrator has a unique developer name and WIP directory
2. **Visibility:** Regular commits to WIP directories keep everyone informed
3. **Sync Points:** Pull before major decisions to see others' progress
4. **Isolation:** Your worktree isolates your changes from others
5. **Independence:** Don't wait for other orchestrators, but stay aware
6. **Communication:** Your worklog + task status = async communication
7. **Conflicts:** Personal branches (main/YourName/TASK-ID) prevent conflicts

**Check for relevant work:**
```bash
# See who's working
ls agents/tasks/wip/

# Find related work
grep -r "FEATURE_NAME" agents/tasks/wip/*/worklog.md

# Check specific developer's progress
cat agents/tasks/wip/Jordan/worklog.md
```

## When Complete

**Final task report:**

```markdown
## Task Completion Report

**Developer:** Alex
**Task:** TASK-XXX.YY - [name]
**Status:** COMPLETE/BLOCKED
**Worktree:** ../project-Alex-TASK-XXX.YY
**Branch:** main/Alex/TASK-XXX.YY

**Summary:**
[What was accomplished or what blocked progress]

**Changes:**
- file1.ext - [what changed]
- file2.ext - [what changed]

**Testing:** [Pass/fail details]
**Ready for merge:** YES/NO

**Related Work by Others:**
[Any relevant work you noticed from other developers]

**My Work Log:** agents/tasks/wip/Alex/worklog.md
```

**STOP** - Your single task is complete. Exit.

## Remember

- Pick a developer name and own it
- Maintain your WIP directory and worklog
- Commit and push frequently for visibility
- Check others' work for context, but work independently
- One task, one worktree, one focus
- Your worklog tells your story to other developers
