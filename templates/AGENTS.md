# AGENTS.md

Instructions for AI coding agents (Cursor, Claude Code, Codex, Copilot).

## Quick Reference

| Task | Command / Pattern |
|------|-------------------|
| Plan before code | Shift+Tab×2 (Plan mode) in Claude Code |
| Long-running task | `/goal <verifiable condition>` |
| Scheduled automation | `/loop 5m <skill or prompt>` |
| Large parallel migration | `/batch "<description>"` |
| Verify frontend work | Browser MCP or Chrome extension |
| Fresh session per task | New chat; don't mix unrelated work |

## Core Rules

1. Read `CLAUDE.md` before making changes.
2. Research existing patterns in the codebase before adding new ones.
3. Minimize diff scope — only change what's required.
4. Run tests/lint before marking work complete.
5. Never commit secrets or modify `.env` files.

## Verification Loop (Boris Cherny)

> The most important tip: give the agent a way to verify its output.

```
1. Implement change
2. Run verification (tests / lint / browser / build)
3. If verification fails → fix → repeat until pass
4. Only then mark complete
```

## Git Conventions

- Branch from `main`: `feature/short-description`, `fix/issue-description`
- Conventional Commits: `type(scope): imperative summary`
- PRs under 400 lines when possible
- Squash merge to `main`

## Prompting (Nate's Patterns)

**Goal-driven:** Transform vague requests into verifiable outcomes.
**Few-shot:** Show format examples when output structure matters.
**Chain-of-thought:** For complex logic, think step-by-step before coding.

When stuck, ask: "What would 'done' look like? What tests prove it works?"
