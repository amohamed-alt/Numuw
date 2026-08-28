# Numuw production polish layer

This branch starts from `design/classy-motherhood-v1` and turns the approved design-preview direction into a production-safe implementation path.

## Open-source motion stack

Numuw intentionally keeps the runtime motion dependency surface small:

- Flutter native animation APIs: press feedback, timers, counters, direct state changes, custom paint.
- `flutter_animate` 4.5.2: concise entrance and micro-interaction effects. BSD-3-Clause.
- `animations` 3.0.0 (Flutter team): Material container transforms and fade-through transitions. BSD-3-Clause.

`flutter_animate` already depends on `flutter_shaders`, so a separate shader package is not added. Rive, Lottie/dotLottie, and Flame are not runtime dependencies until an approved interaction/asset genuinely requires them. This prevents dependency bloat while keeping an upgrade path open.

## Existing motion preserved

The approved Numuw timing system remains authoritative:

- button: 120ms
- card: 280ms
- page: 300ms
- success: 580ms

The new open-source integration does not replace these tokens. It implements them through reusable Numuw wrappers and adds a reduced-motion policy.

## New motion primitives

`lib/widgets/numuw_motion_widgets.dart` now provides:

- `NumuwMotionPolicy`
- `NumuwPressable`
- `NumuwFadeSlideIn`
- `NumuwPulseDot`
- `NumuwAnimatedNumber`
- `NumuwSuccessBloom`
- `NumuwFadeThroughSwitcher`
- `NumuwOpenContainer`
- `numuwPageRoute`

## Agent Skills

Project skills live under `.github/skills/` and are designed for GitHub Copilot agent/CLI use:

- `/numuw-screen-migration`
- `/numuw-motion`
- `/numuw-ui-system`
- `/numuw-rtl-accessibility`
- `/numuw-performance`
- `/numuw-supabase-safety`
- `/numuw-regression`
- `/numuw-release`

Repository-wide rules live in `.github/copilot-instructions.md`.

## Production migration rule

The design preview is a visual source of truth, not a replacement data layer. For every screen migration:

1. Identify the existing production repository/state/actions.
2. Preserve the production contracts.
3. Move the approved visual composition and shared design-system components into the real screen.
4. Add appropriate motion without changing business behavior.
5. Test RTL, Light/Black, reduced motion, loading/empty/error/success states.
6. Run analyzer, tests, Android compile check, and iOS compile check.

Default order: Home → Quick Log → Feeding/Sleep/Pumping → Child → Assistant → auth/onboarding → family/sharing → settings/secondary flows.
