# CLAUDE.md

Project agent instructions. Claude Code reads this automatically each session.

## Behavioral Guidelines (Karpathy)

**Tradeoff:** Bias toward caution over speed. For trivial tasks, use judgment.

### Think Before Coding
- State assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.

### Simplicity First
- Minimum code that solves the problem. Nothing speculative.
- No abstractions for single-use code.
- If you write 200 lines and it could be 50, rewrite it.

### Surgical Changes
- Touch only what you must. Match existing style.
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

### Goal-Driven Execution
Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"

For multi-step tasks, state a brief plan with verify checks per step.

## Boris Cherny Workflow (Claude Code)

1. **Plan mode first** — Use Plan mode (Shift+Tab×2) for harder tasks. Iterate on plan before executing.
2. **Verify output** — Give Claude a way to check its work (tests, browser, lint). Iterate until verified.
3. **One task per session** — Start fresh sessions for new tasks. Use `/branch` or `--fork-session` to explore alternatives.
4. **CLAUDE.md is living docs** — Add anything Claude gets wrong repeatedly to this file.
5. **Parallel worktrees** — Use `claude -w` for parallel sessions on different branches.
6. **Small PRs** — Target <400 lines changed. One logical change per PR.

## Git Workflow (2026 Best Practices)

- **Branching:** Trunk-based. Short-lived branches from `main`: `feature/`, `fix/`, `chore/`.
- **Commits:** [Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`.
- **PRs:** Fill out the PR template. Squash merge to `main`. Delete branch after merge.
- **Never:** Force-push to `main`. Commit secrets (`.env`, credentials). Skip hooks unless explicitly asked.

## Nate's Prompting Patterns (Agentic Era)

When given ambiguous tasks, use goal-driven prompts:
```
Read this repo and session history. Analyze the exact intent and goals.
Write a /goal prompt with verifiable success criteria.
If unclear, ask clarifying questions before implementing.
```

For complex work, define success criteria upfront:
- What does "done" look like? (tests pass, build succeeds, specific behavior verified)
- What should NOT change?
- What verification steps must pass?

## Project-Specific

<!-- Add repo-specific conventions below. Examples: -->
<!-- - Stack: Next.js 15, TypeScript, Tailwind -->
<!-- - Deploy: Vercel. Use `vercel build`, not `npm run build` -->
<!-- - Agent: Dr. Jan Duffy (never "Janet"). License S.0197614.LLC -->
