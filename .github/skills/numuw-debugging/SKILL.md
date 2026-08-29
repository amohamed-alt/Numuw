---
name: numuw-debugging
description: Diagnose and fix Numuw Flutter bugs using a reproduce-first workflow, preserving production behavior and adding regression coverage before closing the issue.
argument-hint: "[bug, error, or failing flow]"
user-invocable: true
---

# Numuw debugging

1. Reproduce or isolate the failure from logs, failing tests, CI, or a deterministic scenario.
2. Trace the actual production path: UI → state → repository/service → Supabase/platform integration.
3. Fix the root cause rather than masking an exception or adding arbitrary delays/retries.
4. Do not replace real behavior with preview/demo fixtures to make a test pass.
5. Preserve Arabic/RTL, Light/Black, lifecycle, offline/error behavior, timers, and navigation state.
6. Add a focused regression test whenever the bug can reasonably recur.
7. Check for adjacent failure modes caused by the same assumption.
8. Run format, analyzer, tests, and the relevant Android/iOS compile check.

Avoid broad unrelated refactors in a bug fix unless they are necessary to remove the root cause safely.
