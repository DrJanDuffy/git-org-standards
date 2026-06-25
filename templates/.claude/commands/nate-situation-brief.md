---
description: Nate 4-level prompting — situation brief before complex agentic work
---

Produce a situation brief before implementing:

## Situation
- What repo/project is this?
- What triggered this task (bug, feature, maintenance)?
- What constraints exist (deploy target, compliance, deadlines)?

## Intent
- What outcome does the user actually want?
- What should NOT change?

## Success criteria (verifiable)
- [ ] Concrete check 1 (e.g. `vercel build` passes)
- [ ] Concrete check 2 (e.g. specific page renders)
- [ ] Concrete check 3 if applicable

## Open questions
List anything ambiguous. Ask before coding if answers change the approach.

## Recommended next step
Single best action: plan-then-build, verify-loop, or direct surgical fix.

Do not implement until success criteria are agreed.
