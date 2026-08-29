---
name: numuw-regression
description: Add or review Numuw Flutter widget and visual regression coverage for production UI states, especially Light/Black variants, Arabic RTL, loading/empty/error/success states, and migrated design-preview screens.
argument-hint: "[screen or flow]"
user-invocable: true
---

# Numuw regression coverage

For each migrated or heavily changed screen:

- Keep behavior tests separate from purely visual assertions where practical.
- Cover at least the default production state plus meaningful loading, empty, error, and success states that exist for the feature.
- Exercise Arabic RTL and both Light and Black visual variants for high-value screens.
- Use deterministic fixtures; never depend on live Supabase/network calls in widget or golden tests.
- Freeze time/timer-dependent values when needed so screenshots are stable.
- Avoid brittle pixel tests for dynamic platform text when a focused widget assertion is more reliable.
- When golden tests are used, rely on Flutter's built-in golden support unless another tool is demonstrably needed.
- Any intentional visual change must update the baseline together with a clear PR explanation.
- Run `flutter test` after adding or updating regression coverage.
