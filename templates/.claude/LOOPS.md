# Boris Cherny Loop Patterns

Inspired by [@bcherny](https://x.com/bcherny) — turn recurring workflows into `/loop` + skills.

## Recommended Loops

Run these in Claude Code from the repo root:

```bash
# Shepherd PRs to production (every 5 min)
/loop 5m /babysit

# Address missed code review comments
/loop /post-merge-sweeper

# Close stale PRs (hourly)
/loop 1h /pr-pruner

# Goal-driven: tests must pass
/goal all tests pass and lint is clean
```

## Loop Design Principles

1. **Iteration > perfection** — Let the loop refine work across turns.
2. **Failures are data** — Each failed verification informs the next attempt.
3. **Verifiable exit** — Use `/goal` with concrete conditions, or `--completion-promise` with Ralph loops.
4. **Safety nets** — Always set `--max-iterations` on unattended loops.

## Creating Custom Loops

1. Write a skill in `.claude/skills/<name>/SKILL.md`
2. Create a slash command in `.claude/commands/<name>.md`
3. Schedule with `/loop <interval> /<name>`

Example intervals: `5m`, `30m`, `1h`, `1d`

## Hooks for Deterministic Behavior

Configure in `.claude/settings.json`:

| Hook | Use case |
|------|----------|
| `SessionStart` | Load context, run `git status` |
| `PreToolUse` | Log bash commands |
| `PostToolUse` | Auto-format after Write/Edit |
| `Stop` | Poke agent to continue if work incomplete |

See [Claude Code hooks docs](https://code.claude.com/docs/en/hooks).
