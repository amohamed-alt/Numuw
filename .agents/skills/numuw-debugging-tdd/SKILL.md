---
name: numuw-debugging-tdd
description: Evidence-first debugging, TDD, code review, and architecture improvement for Numuw. Use for bugs, regressions, refactors, and risky feature work.
metadata:
  project: Numuw
  upstream:
    - mattpocock/skills
---
# Numuw Debugging and TDD

## Evidence-first debugging
Do not guess-fix. Follow this order:
1. Reproduce the defect.
2. Record the exact failing behavior and environment.
3. Form the smallest plausible hypothesis.
4. Add instrumentation or a targeted test to prove/disprove it.
5. Fix the root cause, not the visible symptom.
6. Add a regression test.
7. Re-run the full relevant quality gate.

For web: verify network assets, bootstrap, plugin registration, runtime JS/Dart exception, first Flutter frame, and rendered DOM/view separately.

## Test-driven feature work
For risky business logic, write the acceptance test first or alongside the change. Prioritize auth, child authorization, care-event logging, timers, analytics, AI response parsing, family sharing, and health-safety flows.

## Review rules
A review must look for:
- wrong behavior and edge cases;
- lifecycle/null/async bugs;
- authorization bypasses and insecure defaults;
- child-data leakage across accounts/children;
- state that can desync after retries/offline use;
- hidden platform incompatibility;
- UI regression against Figma and RTL;
- missing failure-path tests.

## Architecture improvement
Refactor only when it reduces a demonstrated problem: duplication, untestable coupling, unclear boundaries, state drift, or repeated defects. Preserve behavior with tests before moving code.

## Completion definition
A bug is not fixed because the line changed. It is fixed when the original reproduction no longer fails, the regression test passes, and the relevant app target starts and renders successfully.

## Upstream guidance incorporated
Adapted from high-value skills in `mattpocock/skills`: `diagnosing-bugs`, `tdd`, `code-review`, and `improve-codebase-architecture`.