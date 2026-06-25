---
description: SEO drift check loop for real estate sites (NAP, schema, GBP alignment)
---

Audit this site for local SEO drift. Check:

1. **NAP consistency** — Business name, address, phone match GBP exactly (visible + JSON-LD)
2. **LocalBusiness schema** — Present on all pages, hours/attributes current
3. **Title/H1** — Localized, reference service area
4. **Core files** — `sitemap.ts`, `robots.txt`, canonical URLs
5. **RealScout/CSP** — If widgets present: `em.realscout.com` + `www.realscout.com` in CSP

Report findings as:
- PASS items
- DRIFT items (what changed, suggested fix)
- BLOCKERS (need human/GBP update)

Do not auto-fix MLS/IDX compliance components without explicit approval.
