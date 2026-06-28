# Global OpenCode Agent Instructions

## General Guidelines

- Avoid verbosity. Responses always concise, terse, purpose clear.
- NEVER edit/commit/push git unless explicit ask. Git read-only by default.

## Documentation Style

- Markdown / long strings: favour line breaks.
  - Never multiple sentences same line.

## Code Style Guidelines

- Prefer early return over nested if/else.
- Prefer immutable variables + iterators/closures, even if language does not enforce.
- Avoid `try` / `catch`; only use if absolutely necessary.
- Avoid `any`/`object`; use generics + strong types.
- Use idiomatic style, names, tests for language.
  - Prefer language idiomatics, surface opportunity to refactor code if not following community standards

## Tool Usage

- Use parallel tools / subagents where useful. Async work, clean context.
- Batch reads, searches, independent operations.
- Target searches + reads. Wide patterns destroy context.

## Technology Preferences

### Development Tools

- Unless project says otherwise, prefer:
  - bun/bunx for javascript
  - uv/uvx for python
  - cargo for rust
  - nix for dev shells and isolated shell commands
