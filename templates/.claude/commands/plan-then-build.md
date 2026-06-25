---
description: Plan-then-build with advisor review before implementation (Boris + Claude Advisor)
---

Before writing any code:

1. **Nate situation brief** — State: context, intent, constraints, what "done" looks like
2. **Plan** — Numbered steps, each with `verify:` check (Karpathy goal-driven)
3. **Advisor review** — Challenge assumptions, flag scope creep, confirm verification is sufficient
4. **Implement** — Surgical changes only after plan is approved
5. **Verify-loop** — Run `/verify-loop` before declaring done

If the task touches 3+ files or production config, advisor review is mandatory.

Output plan first. Wait for approval unless user granted full permission and risk is low.
