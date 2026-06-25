# Contributing

## Git Workflow (2026)

We use **trunk-based development** with short-lived feature branches.

### Branch naming

```
feature/short-description
fix/issue-description
chore/task-description
docs/what-changed
```

### Commits

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat(auth): add OAuth login
fix(api): handle null response from MLS feed
docs: update deployment instructions
chore(deps): bump next to 15.2
```

### Pull Requests

1. Branch from `main`
2. Keep PRs under 400 lines when possible
3. Fill out the PR template
4. Squash merge after review + CI pass
5. Delete branch after merge

### AI-Assisted Development

This repo includes `CLAUDE.md` and `AGENTS.md` for AI coding agents.

- Update `CLAUDE.md` when you find recurring agent mistakes
- Use Plan mode before large changes
- Always verify: tests, lint, browser (for UI)

### Pre-commit

```bash
pip install pre-commit
pre-commit install
```

### Local setup

```bash
git clone <repo-url>
cd <repo>
# Follow repo-specific README for install steps
```
