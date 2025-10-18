# PRD: Requirement Refinement

> **USER COMMAND** - Refine user requirements in place
> 
> **Agent:** Read user's requirement file (agents/[filename].md) and expand it with clear, user-focused requirements.
>
> **CRITICAL:** Write sections directly to the user-specified file incrementally. Save after each section to support recovery.

## Your Task

User provides a file path in `agents/` containing their initial requirement.
Read that file and expand it in place by adding sections that clarify:
1. **What** they want (user perspective, not technical implementation)
2. **Why** it matters (user benefit, problem being solved)
3. **How** they'll use it (workflows, scenarios)
4. **When** it's done right (observable success criteria)

**CRITICAL:** Save file after completing each section. This enables recovery if interrupted.

## Append These Sections to User's File

```markdown
---

## Refined Requirements

### Overview
[1-2 paragraphs: What is this? Why does it matter?]
[SAVE FILE]

### User Stories
- As a [user], I want [goal] so that [benefit]
- As a [user], I want [goal] so that [benefit]
[SAVE FILE]

### Core Functionality
1. [What the system must do - user observable behavior]
2. [What the system must do - user observable behavior]
[SAVE FILE]

### User Workflows
1. **[Scenario name]**
   - User does [action]
   - System responds [behavior]
   - Result: [outcome]
[SAVE FILE]

### Success Criteria
- [ ] User can [do something observable]
- [ ] System behaves [in expected way]
- [ ] [Measurable outcome achieved]
[SAVE FILE]

### Testing Approach
- **Check if project has test framework** (tests/ dir, test files, test deps)
- **If YES**: [Test scenarios needed]
- **If NO**: [Manual verification steps - agent uses agents/sandbox/ for testing, removes all artifacts after]
[SAVE FILE]

### Constraints & Assumptions
- [What we're assuming about users/environment]
- [Known limitations]
[SAVE FILE]

### Open Questions
**IMPORTANT:** Only ask questions that significantly impact scope, architecture, or user experience.
Do NOT ask about:
- Nitpicky implementation details (agent decides simple things)
- Code style/formatting (follow project conventions)
- Trivial naming (agent decides, use project conventions)
- Minor edge cases (handle sensibly)

**DO ask about:**
- Ambiguous scope or requirements
- Breaking changes or backwards compatibility
- Major architectural decisions
- User-facing behavior that could go multiple ways
- Security/privacy implications
- Performance/scale concerns

[List only key questions that need user input]
[SAVE FILE]

### Out of Scope
- [What this explicitly does NOT include]
[SAVE FILE]
```

## Status Updates

Add to top of file as you work:
```markdown
**Status:** REFINING → REFINE_COMPLETE
**Refined:** YYYY-MM-DD
```

## When Complete

1. Ensure all sections written to file
2. Set status: `REFINE_COMPLETE`
3. Present summary to user
4. Ask ONLY key questions that impact scope/architecture/UX (see Open Questions guidance)
5. **STOP** - User will explicitly invoke Tasks stage when ready

## Focus

- **DO**: Focus on user perspective, behavior, observable outcomes
- **DON'T**: Get into technical implementation, architecture, data models
- **DO**: Ask clarifying questions if request is vague
- **DON'T**: Assume technical details - that's for the Tasks stage
