# Numuw repository instructions

Numuw is a production Flutter motherhood application in Arabic-first RTL with light and black visual variants. The current `design/classy-motherhood-v1` lineage contains a full design-preview layer plus existing production business logic, repositories, Supabase integration, auth, notifications, and local app state.

## Non-negotiable rules

- Preserve existing business logic, repositories, Supabase schema/contracts, auth behavior, persistence, and notification behavior unless the task explicitly changes them.
- Migrate design-preview UI into production screen-by-screen; do not replace production data access with demo data.
- Reuse the Numuw design system before creating new widgets. Prefer `NumuwClassyButton`, existing surfaces, identity components, metrics, quick actions, segmented controls, timelines, and navigation primitives.
- Never hardcode a new color, spacing scale, typography family, corner system, or motion duration when a Numuw token already exists.
- Arabic/RTL is first-class. Every production UI change must also remain valid in LTR where supported.
- Keep primary actions reachable one-handed and touch targets at least 44 logical pixels.
- Every screen must handle loading, empty, error, success, and disabled states where applicable.

## Motion

- Numuw motion is calm, reassuring, and premium; never game-like.
- Use existing `NumuwMotionTokens` durations and curves.
- Native Flutter remains preferred for direct state feedback and simple animations.
- Use `flutter_animate` for concise entrance/micro-interaction sequences.
- Use the `animations` package for meaningful container transforms and fade-through navigation/state changes.
- Respect `MediaQuery.disableAnimations`; decorative animation must disappear when reduced motion is requested.
- Do not add Rive, Lottie, Flame, or another animation dependency until a concrete asset/interaction requires it.

## Engineering quality

- Prefer small reusable widgets over duplicating large screen fragments.
- Avoid unnecessary rebuilds and repeated async calls from `build`.
- Dispose controllers/subscriptions/timers.
- Keep secrets and Supabase service-role credentials out of the client and repository.
- Run `flutter pub get`, `dart format`, `flutter analyze`, and `flutter test` after code changes.
- For UI changes, add or update widget/golden regression coverage when practical.
- Android and iOS builds must remain healthy; web preview is a design/testing surface, not the product architecture.

## Production migration order

Default migration sequence unless a dependency requires otherwise:
1. Home
2. Quick Log
3. Feeding / Sleep / Pumping
4. Child
5. Assistant
6. Auth / onboarding
7. Family / sharing
8. Settings and remaining secondary flows

When migrating a screen, first identify its production data dependencies and actions, then apply the design-preview composition around those existing contracts.
