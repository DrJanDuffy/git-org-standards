---
description: Commit, push, and open a PR with conventional commit
---

1. Run `git status` and `git diff` to understand changes
2. Stage only relevant files (never `.env` or secrets)
3. Write a conventional commit message: `type(scope): summary`
4. Push to a feature branch (create if on main)
5. Open a PR using `gh pr create` with the PR template
6. Return the PR URL
