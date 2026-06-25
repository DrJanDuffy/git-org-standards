# Git Org Standards

Centralized Git/GitHub best practices for **DrJanDuffy** repositories.

Based on:
- **Boris Cherny** ([@bcherny](https://x.com/bcherny)) — Claude Code loops, hooks, parallel worktrees, Plan mode
- **Andrej Karpathy** — Surgical changes, goal-driven execution, verifiable success criteria
- **Nate B. Jones** ([Substack](https://natesnewsletter.substack.com/)) — Production-grade prompting patterns
- **2026 Git workflow** — Trunk-based dev, Conventional Commits, GitHub Flow, small PRs

## What's Included

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Agent instructions (Karpathy + Boris + Nate patterns) |
| `AGENTS.md` | Cursor/Codex/Copilot agent reference |
| `CONTRIBUTING.md` | Branch naming, commits, PR workflow |
| `.github/workflows/ci.yml` | Lint, test, standards validation |
| `.github/pull_request_template.md` | PR checklist |
| `.claude/commands/` | Boris-style loops: `/babysit`, `/pr-pruner`, etc. |
| `.claude/LOOPS.md` | Loop design guide |
| `.pre-commit-config.yaml` | Secret detection, commitlint, formatting |
| `commitlint.config.mjs` | Conventional Commits enforcement |

## Apply to All Repos

```powershell
# Dry run (safe — no pushes)
.\scripts\apply-standards.ps1 -DryRun

# Apply to all repos (additive only, no branch rename)
.\scripts\apply-standards.ps1

# Single repo
.\scripts\apply-standards.ps1 -Repo centennialhillshomesforsale

# Use local clones instead of temp dir
.\scripts\apply-standards.ps1 -LocalRoot C:\Users\geneb\projects

# DANGER: rename master→main (update Vercel prod branch first!)
.\scripts\apply-standards.ps1 -RenameBranches
```

## Global Git Config

```powershell
# Safe settings (default branch, fetch prune, aliases)
.\scripts\setup-global-git.ps1

# Verify GPG signing before enabling
.\scripts\verify-gpg-signing.ps1
.\scripts\setup-global-git.ps1 -EnableSigning
```

## Boris Cherny Loops (Claude Code)

```bash
/loop 5m /babysit              # Shepherd PRs to production
/loop /post-merge-sweeper      # Fix missed review comments
/loop 1h /pr-pruner            # Close stale PRs
/goal all tests pass and lint is clean
```

## Customize Per Repo

After applying, edit the `## Project-Specific` section in each repo's `CLAUDE.md`.

## Sources

- [Boris Cherny 15 tips (Mar 2026)](https://x.com/bcherny/status/2038454336355999749)
- [Karpathy Guidelines](https://github.com/forrestchang/andrej-karpathy-skills)
- [Karpathy LLM Wiki gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
- [Nate's Prompt Stack](https://natesnewsletter.substack.com/p/my-prompt-stack-for-work-16-prompts)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Flow](https://docs.github.com/en/get-started/using-github/github-flow)
