---
name: numuw-code-review
description: Review Numuw Flutter pull requests for correctness, regressions, architecture drift, duplicated design components, lifecycle issues, performance, RTL/accessibility, Supabase safety, and missing tests.
argument-hint: "[PR, diff, or feature]"
user-invocable: true
---

# Numuw code review

Prioritize findings by production risk, not style preference.

Check:

1. Does the change preserve existing business and repository contracts unless explicitly intended?
2. Did preview/demo data leak into a production route?
3. Is the approved Numuw design system reused instead of duplicated/hardcoded?
4. Are timers, controllers, subscriptions, and lifecycle state safe?
5. Are async calls/rebuilds/list rendering efficient?
6. Does Arabic RTL, text scaling, Light/Black, reduced motion, safe areas, and 44px touch sizing still work?
7. Are Supabase/RLS/family privacy boundaries preserved?
8. Are loading/empty/error/success/disabled paths handled?
9. Are failures surfaced clearly rather than silently swallowed?
10. Is test/regression coverage proportional to the risk?

Report concrete file/behavior findings first, then improvements. Do not block a PR for subjective cleanup unrelated to correctness or the approved design system.
