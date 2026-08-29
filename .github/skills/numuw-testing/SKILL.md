---
name: numuw-testing
description: Design and implement Numuw Flutter unit, widget, integration, and visual regression tests for production behavior without live-network or flaky timing dependencies.
argument-hint: "[feature, screen, or flow]"
user-invocable: true
---

# Numuw testing

Choose the smallest test layer that proves the behavior:

- Unit tests for formatting, calculations, mapping, validation, and repository-independent logic.
- Widget tests for screen states, actions, RTL/layout behavior, and UI/repository interaction through deterministic fakes.
- Integration tests for critical multi-screen flows such as auth/onboarding and core logging when widget tests cannot prove the contract.
- Golden tests for approved high-value visual states only; keep fixtures, time, locale, surface size, and theme deterministic.

Required principles:

- No live Supabase/network dependency in unit/widget/golden tests.
- Cover success plus meaningful loading/empty/error/disabled states.
- Include Arabic RTL and Light/Black where visual/layout risk is material.
- Freeze clocks/timers where time appears in assertions or screenshots.
- Prefer behavior assertions over brittle implementation details.
- Any fixed production bug should gain a regression test where feasible.
- Run the full `flutter test` suite after changes.
