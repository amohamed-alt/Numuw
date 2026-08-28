---
name: numuw-flutter-engineering
description: Production Flutter engineering rules for Numuw. Use for architecture, responsive layout, widget/integration testing, routing, localization, JSON/API work, and layout fixes.
metadata:
  project: Numuw
  upstream:
    - flutter/agent-plugins
    - dart-lang/skills
---
# Numuw Flutter Engineering

Use this skill for any Flutter implementation or refactor in Numuw.

## Non-negotiables
- Figma Make is the visual source of truth unless accessibility, security, or store policy requires a deliberate deviation.
- Arabic RTL is first-class. Test RTL, small phones, text scaling, Light, Dark, and reduced-motion behavior.
- Preserve existing repositories, models, timers, health-safety rules, RLS assumptions, and offline behavior while changing UI.
- Prefer small reusable widgets and pure helpers. Keep business logic out of large screen widgets.
- Never make a large unrelated rewrite to solve a local bug.

## Required workflow
1. Inspect the existing screen, state, services, tests, and Figma target before editing.
2. Reproduce the problem or define acceptance criteria.
3. Make the smallest coherent change.
4. Add or update tests before calling the work complete.
5. Run `flutter analyze --no-fatal-infos` and `flutter test -r expanded`.
6. For platform, routing, dependency, or release changes, build the affected target.

## Testing
- Add widget tests for UI state and interaction changes.
- Add integration tests for critical journeys: signup/signin, child onboarding, logging, dashboard, assistant, family sharing, and account settings.
- Use stable `ValueKey`s on critical interactive controls when needed by integration tests.
- Do not delete or weaken tests just to make CI pass.
- A successful compile is not a runtime proof. Web changes require a browser smoke test that confirms a Flutter view rendered.

## Layout and responsive behavior
- Canonical design viewport: 390×844, but never hard-code the whole UI to that size.
- Minimum practical touch targets: 48×48.
- Use SafeArea where relevant.
- Avoid overflow at 320px-class widths and with increased text scale.
- Desktop web preview should frame the mobile app rather than stretch the mobile layout arbitrarily.

## Architecture
- UI -> state/controller -> repository/service -> Supabase/API.
- Keep serialization and mapping outside widgets.
- Keep platform-specific code behind services and guard unsupported web/native behavior.
- Prefer explicit state and typed models over unstructured maps in UI code.

## Routing and localization
- Preserve the five-tab product IA: اليوم، التسجيل، طفلي، اسألي نُمُوّ، المزيد.
- Deep links must not bypass authentication or child authorization.
- All user-facing strings should remain Arabic-first and be ready for localization; do not introduce mixed hard-coded English UI without product intent.

## API / JSON
- Validate server responses before using them.
- Map transport errors to user-safe domain errors.
- Never expose provider secrets in Flutter.
- Do not claim an attachment or action succeeded unless the backend actually processed it.

## Upstream guidance incorporated
Curated from Flutter official agent skills including `flutter-add-integration-test`, `flutter-add-widget-test`, `flutter-add-widget-preview`, `flutter-apply-architecture-best-practices`, `flutter-build-responsive-layout`, `flutter-fix-layout-issues`, `flutter-implement-json-serialization`, `flutter-setup-declarative-routing`, `flutter-setup-localization`, and `flutter-use-http-package`.