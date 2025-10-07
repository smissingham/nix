# Global OpenCode Agent Instructions
---

This is a global configuration file that applies to all projects unless overridden by project-specific `AGENTS.md` files.

## General Guidelines

- Avoid verbosity in all places. Be concise, but descriptive toward purpose/intent.
- Always consider the perspective of a junior developer, or business user, in that you shouldn't assume high levels of technical background
    - With this in mind, write functions & structure code in a way that is domain driven as much as possible.

## Code Style Guidelines

- Prefer early return pattern over nested if/else structures
- Always try to use variables as immutable, with use of iterators/closures, even if the language doesn't technically support it
- Avoid `try` / `catch` unless truly necessary
- Avoid using `any`/`object` general types, instead use proper generics if available and always prefer strong typing
- Always use most language-idiomatic approaches to code style, function naming, test definitions etc.

## Tool Usage

- Use parallel tools / subagents for task delegation whenever possible for asynchronous work and context window cleanliness
- Batch file reads, searches, and other independent operations together
- Be targeted with searches & reads, wide search patterns will destroy context window

## Technology Preferences

### Development Tools
- Prefer built-in APIs over external dependencies
- Leverage language-specific tooling already in the environment

- Strongly prefer to use context7 documentation tooling for latest practices after your training window.

- Unless the project is set up otherwise, always prefer:
    - bun/bunx for javascript
    - uv/uvx for python
    - cargo for rust
    - just for task running & ci/cd reusability
    - nix for dev shells and isolated shell commands

---
