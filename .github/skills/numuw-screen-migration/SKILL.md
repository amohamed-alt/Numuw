---
name: numuw-screen-migration
description: Convert a Numuw design-preview screen into the real production Flutter screen while preserving existing repositories, Supabase contracts, auth, persistence, timers, notifications, and business behavior. Use for Home, Quick Log, feeding, sleep, pumping, child, assistant, onboarding, family, settings, and other screen migrations.
argument-hint: "[screen or flow]"
user-invocable: true
---

# Numuw screen migration

1. Inspect both the design-preview implementation and the current production screen.
2. List the production data sources, repositories, state objects, callbacks, timers, navigation, persistence, and side effects used by the existing screen.
3. Keep those contracts intact. Demo/preview values must never replace real data.
4. Rebuild the presentation using the current Numuw classy design components and tokens.
5. Reuse shared components before creating another screen-specific version.
6. Preserve Arabic-first RTL, semantic labels, one-handed reachability, safe areas, keyboard behavior, and 44px minimum touch targets.
7. Implement loading, empty, error, success, disabled, and offline-recoverable states where the feature supports them.
8. Use Numuw motion primitives; respect reduced-motion preferences.
9. Avoid changing the database schema during a visual migration unless the feature genuinely requires new data.
10. Add/update tests covering the migrated production behavior and key visual states.
11. Run formatting, analyzer, tests, and relevant mobile build checks.

Definition of done: the production route uses real app data/actions and visually matches the approved preview direction without breaking the previous business logic.
