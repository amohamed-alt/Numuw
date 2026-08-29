---
name: numuw-release
description: Prepare Numuw Flutter for a production Android/iOS release by checking tests, analyzer, package state, permissions, identifiers, signing readiness, secrets, Supabase config, notifications, versioning, and release builds.
argument-hint: "[android|ios|both]"
user-invocable: true
---

# Numuw release check

Before calling a build production-ready:

1. Resolve packages and ensure the lockfile is current.
2. Run formatting, analyzer, and all tests.
3. Build Android and iOS release artifacts (iOS may use `--no-codesign` in CI until signing credentials are configured).
4. Check bundle/application identifiers, version/build number, display name, icons, splash, permissions, privacy strings, notification configuration, and deep-link/auth callback configuration.
5. Verify no secrets, service-role keys, local debug URLs, preview flags, or test credentials are shipped.
6. Confirm production routes use real repositories/data rather than design-preview fixtures.
7. Verify auth, onboarding, Home, Quick Log, core logging flows, Child, Assistant, family sharing, settings, and sign-out on a clean install.
8. Check Light/Black, RTL, reduced motion, offline/error recovery, and background/resume behavior.
9. Document any store-side/signing prerequisites that cannot live in source control.

Do not mark the app ready solely because the web preview builds.
