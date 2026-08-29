# Numuw AI Engineering Playbook

## Product mission
Numuw is an Arabic-first family companion from pregnancy through the child's first years. The product helps caregivers record routines, understand trends, prepare for doctor visits, organize vaccinations/medications, and receive safe non-diagnostic guidance.

## Non-negotiable product rules
- Arabic-first and RTL-first. English/LTR must remain possible.
- One-handed mobile use: primary actions must be reachable, large, and quick.
- Never diagnose, prescribe, change a dose, reassure that a child is medically safe, or delay urgent care.
- Medical content must show a source/review date before production publication.
- Never expose Supabase secret/service-role keys, AI provider secrets, Sentry auth tokens, signing keys, or store credentials in client code or Git.
- Every public Supabase table must have RLS and ownership/guardian authorization.
- Family access is explicit and least-privilege.
- Offline logging must not lose a care event.
- Timers must be based on persisted timestamps, not only an in-memory ticker.

## Canonical architecture
Use feature-oriented clean layers without unnecessary abstraction:

- `lib/core/`: app boot, configuration, errors, theme, platform services.
- `lib/design/`: Numuw organic design system, SVG assets, motion primitives.
- `lib/models/`: immutable domain models and serialization.
- `lib/repositories/`: all database/data-source access.
- `lib/services/`: cross-feature orchestration such as notifications, reports and AI.
- `lib/screens/`: route-level UI only. Avoid business logic here.
- `lib/widgets/`: reusable general-purpose UI.
- `supabase/migrations/`: versioned database changes.
- `supabase/functions/`: privileged/server-side workflows only.
- `test/`: model, repository, service and critical widget coverage.

## Design skill
The approved Numuw visual language is **Natural Organic**:
- warm off-white surfaces
- eucalyptus/sage greens
- muted teal
- peach/apricot accents
- dusty blue/lavender support accents
- rounded organic geometry
- subtle botanical leaf details
- gentle soft shadows, never glassmorphism-heavy
- illustrations feel human, calm, warm and contemporary

Never reintroduce the old generic purple-only visual language. New UI should use design tokens, not arbitrary literals.

## SVG skill
- Functional icons are SVG-first.
- Use `NumuwOrganicIcon` as the single icon vocabulary.
- Keep icons readable at 20–28 px and illustrations at larger sizes.
- Avoid embedded raster images inside SVG.
- Prefer simple paths/primitives for performance.
- Decorative leaf accents must never reduce icon recognizability.

## Motion skill
Motion exists to communicate state, not decorate every surface.
- tap: 90–140 ms scale/opacity response
- card entrance: 220–320 ms fade + small slide
- success: 350–650 ms spring/check flourish
- timers: continuous UI updates while truth comes from timestamps
- respect reduced-motion/accessibility preferences
- use Flutter implicit/explicit animation for interface motion
- use Rive only for high-value character/hero sequences when a real `.riv` asset is supplied; do not add Rive just for static icons

## Supabase skill
- Current project uses Supabase Auth + Postgres + RLS + Edge Functions.
- Use the publishable key in the app; never the service role.
- Every `UPDATE` RLS policy requires both `USING` and `WITH CHECK` and an applicable `SELECT` policy.
- `TO authenticated` is not authorization by itself; require ownership or valid child membership.
- Do not use `user_metadata` for authorization.
- Prefer security-invoker database behavior; SECURITY DEFINER requires an explicit security review.
- After DDL: run Supabase security and performance advisors and fix actionable findings.

## AI assistant skill
- The assistant may summarize user-entered logs, prepare doctor questions, explain general concepts and surface emergency red flags.
- It may not diagnose or prescribe.
- Sensitive context sent to an AI provider must be minimized.
- Keep provider API keys in server-side environment secrets only.
- Log usage metadata without storing unnecessary prompt content.
- Include safe fallbacks when AI is unavailable.

## Offline/sync skill
- Logging must be optimistic and resilient.
- Generate stable client IDs/idempotency keys for writes that can retry.
- Queue failed writes and flush on connectivity/session recovery.
- Resolve server timestamps explicitly; do not silently overwrite another caregiver's data.

## Notifications skill
- Notifications are reminders, never medical conclusions.
- Deep-link to the relevant record/flow.
- Handle denied permissions gracefully.
- Avoid duplicate reminders after a record is completed.

## Observability skill
- Sentry is initialized only when `SENTRY_DSN` is configured.
- Separate `APP_ENV` values for development/staging/production.
- Do not attach health notes, document contents, auth tokens, email, phone, or other sensitive child/family content to error events.
- Capture unexpected errors and degraded service states; expected validation failures stay local.

## Testing skill
Before merging changes:
1. `flutter pub get`
2. `dart format --set-exit-if-changed lib test`
3. `flutter analyze`
4. `flutter test`
5. Build at least the web target in CI; mobile release builds require signing environments.
6. For schema changes: run security/performance advisors.

Critical flows requiring tests:
- authentication gate
- onboarding and active child selection
- feeding/sleep/diaper/medicine event creation
- timer restoration
- offline retry
- family authorization
- AI safety parsing/fallback
- doctor report generation
- vaccination completion

## Git/AI workflow
- Work on a feature branch.
- Keep migrations, client model/repository changes and tests in the same PR when schema behavior changes.
- Never mass-rewrite working code only to match a fashionable architecture.
- Prefer incremental refactors with passing tests.
- Update `docs/PRODUCT_BUILD_MAP.md` when a feature changes status or scope.
