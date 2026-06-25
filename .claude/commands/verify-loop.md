---
description: Iterative verify loop — run tests/build until green (Boris Cherny pattern)
---

Run the verification loop for this repo:

1. Identify the correct verify command:
   - Node/Next.js: `npm run lint` then `vercel build` (or `npm test` if configured)
   - Python: `ruff check .` then `pytest` if configured
2. Run verification
3. If failures: fix surgically (Karpathy rules), re-run
4. Loop until all checks pass OR you hit a blocker needing human input
5. Report: what passed, what you fixed, what remains

Do NOT mark complete until verification output shows green.
