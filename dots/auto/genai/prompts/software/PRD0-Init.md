# PRD: Project Initialization

> **USER COMMAND** - Initialize PRD workflow structure
> 
> **Agent:** Create directory structure and configuration for the PRD workflow.

## Directory Structure

```
agents/
├── tasks/
│   ├── todo/              # Task files ready for execution
│   │   └── .gitkeep
│   ├── wip/               # Git-ignored tasks currently in progress
│   │   └── .gitkeep
│   ├── blocked/           # Git-ignored tasks waiting for user assistance
│   │   └── .gitkeep
│   └── done/              # Git-ignored completed tasks
│       └── .gitkeep
└── sandbox/               # Git-ignored testing workspace for manual verification
    └── .gitkeep
```

```bash
mkdir -p agents/tasks/{todo,wip,blocked,done} agents/sandbox
touch agents/tasks/{todo,wip,blocked,done}/.gitkeep agents/sandbox/.gitkeep
```

## Update .gitignore

```gitignore
# PRD Workflow
agents/**
!**/.gitkeep
!agents/tasks/todo/**
```

## Workflow

```
User creates requirement file: agents/feature-name.md
  ↓
Agent refines in place (adds sections to same file)
  ↓
Agent generates discrete task files → agents/tasks/todo/TASK-XXX.YY-brief-name.md
  ↓
Agent executes tasks → moves to agents/tasks/wip/
  ↓
Blocked? → agents/tasks/blocked/
Complete? → agents/tasks/done/
```

## Verification

```bash
ls -la agents/
git status agents/  # Should show tasks/todo/ tracked, wip/blocked/done/ and sandbox/ ignored
```

## Output

Report:
- ✅ Directory structure created
- ✅ .gitignore updated
- Next: Create requirement file in `agents/` and run Refine stage
