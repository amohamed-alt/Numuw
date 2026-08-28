---
name: numuw-dart-quality
description: Dart correctness and maintainability rules for Numuw. Use for runtime errors, static analysis, dependency conflicts, unit tests, mocks, and coverage.
metadata:
  project: Numuw
  upstream:
    - flutter/agent-plugins
    - dart-lang/skills
---
# Numuw Dart Quality

## Debugging runtime failures
- Reproduce first. Capture the exact exception, stack, platform, route/state, and triggering input.
- Map minified web stacks back to Dart with source maps when needed.
- Distinguish compile success from runtime success.
- Check generated plugin registration when a web crash happens before the first Flutter frame.
- Add a regression test for every fixed production/runtime bug when practical.

## Static analysis
Run:
```bash
flutter analyze --no-fatal-infos
```
Treat warnings that affect lifecycle, null-safety, async context, deprecated APIs, platform support, or security as actionable even when CI is configured not to fail on info-level diagnostics.

## Unit tests
- Prefer deterministic pure-function tests for calculations and mapping.
- Test null/empty/legacy payloads at model boundaries.
- Test child isolation for analytics and timers.
- Test date/time behavior across UTC/local boundaries.
- Test failure paths, not only happy paths.

## Coverage
Coverage is a signal, not the goal. Prioritize branches that protect auth, child authorization, health data, timers, logging, AI parsing, storage, and release-critical logic.

## Dependency changes
Before changing a dependency:
1. Identify why the package is needed and the current transitive graph.
2. Check web/native implementations and platform registration.
3. Prefer compatible upgrades over broad dependency churn.
4. Re-run analyze, tests, web build, and relevant native builds.
5. Verify startup/runtime, especially for plugins with web implementations.

## Null safety
Never silence a null crash with `!` unless the invariant is proven at that boundary. Prefer validation, typed defaults, or explicit error states.

## Upstream guidance incorporated
Curated from official Dart/Flutter skills: `dart-add-unit-test`, `dart-collect-coverage`, `dart-fix-runtime-errors`, `dart-generate-test-mocks`, `dart-resolve-package-conflicts`, and `dart-run-static-analysis`.