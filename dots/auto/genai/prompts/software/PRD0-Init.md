# PRD: Project Initialization

> **USER COMMAND** - Initialize PRD workflow structure
> 
> **Agent:** Create directory structure and configuration for the PRD workflow.

## Directory Structure

```
agents/
├── requirements/
│   ├── features/          # Larger feature requests, built slowly and considerately
│   └── improvements/      # Ad hoc improvement ideas and small notes
├── tasks/
│   ├── wip/               # Git-ignored work-in-progress tasks
│   │   └── .gitkeep
│   ├── done/              # Git-ignored completed tasks
│   │   └── .gitkeep
│   └── blocked/           # Git-ignored blocked tasks
│       └── .gitkeep
├── sandbox/               # Git-ignored testing workspace for manual verification
│   └── .gitkeep
└── TASK-TEMPLATE.md       # Template for new task files
```

```bash
mkdir -p agents/requirements/{features,improvements} agents/tasks/{wip,done,blocked} agents/sandbox
touch agents/requirements/.gitkeep agents/tasks/{wip,done,blocked}/.gitkeep agents/sandbox/.gitkeep
```

## Update .gitignore

```gitignore
# PRD Workflow
agents/**
!**/.gitkeep
```

## Task File Template

Create `agents/TASK-TEMPLATE.md`:

```markdown
# Task: [Brief Title]

**Task ID:** TASK-XXX.00  (Agent assigns sequential PRD IDs: 001.00, 002.00, etc.)
**Created:** YYYY-MM-DD
**Status:** TODO

---

## Original Request

[User's request here]

---

## Refined Requirements

[Refine stage writes here incrementally]

---

## Task Breakdown

[Tasks stage writes here incrementally]
[If multiple tasks needed, use XXX.01, XXX.02, etc.]

---

## Execution Log

[Execution stage writes here incrementally]
```

## Workflow

```
User creates:
  - agents/requirements/features/feature-name.md (larger features)
  - agents/requirements/improvements/improvement-name.md (ad hoc improvements)
  ↓
Agent assigns TASK-XXX.00, works in: agents/tasks/wip/TASK-XXX.00-brief-name.md
  (Refine → Tasks → Execute)
  - If multiple tasks needed: TASK-XXX.01, TASK-XXX.02, etc.
  ↓
Complete: Move to agents/tasks/done/
```

## Verification

```bash
ls -la agents/
git status agents/  # Should show requirements/ tracked, tasks/wip/ and tasks/done/ ignored
```

## Output

Report:
- ✅ Directory structure created
- ✅ .gitignore updated
- ✅ Template created
- Next: Create requirement file in `agents/requirements/`
