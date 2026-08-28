# Numuw AI Engineering Rules

This file is the operating contract for AI coding agents working in this repository.

## Product

Numuw (نُمُوّ) is an Arabic-first motherhood and child-care application built with Flutter and Supabase. Arabic RTL is a first-class experience, not a translation layer added later.

## Source of truth

- Stable base: `main`.
- Current product redesign: `numuw-redesign` until it is formally merged.
- **Visual source of truth:** Figma Make file `iqGCXUtDntKrQ13WTC3TYp` — `Utilize Provided Prompt`.
- Figma URL: `https://www.figma.com/make/iqGCXUtDntKrQ13WTC3TYp/Utilize-Provided-Prompt`
- When Flutter and Figma differ visually, match Figma unless platform accessibility, security, or store requirements require a deliberate deviation.
- Preserve existing Supabase repositories, models, RLS, timers, notifications and health-safety behavior while matching the design.
- Never merge a large visual or data-layer change directly into `main`.
- Work in a focused branch and open a pull request.

## Local engineering skills

Numuw has a curated local agent skill set under `.agents/skills/`. Read `NUMUW_SKILLS.md` and activate the relevant local skill(s) before non-trivial work.

- Flutter UI/feature work: `numuw-flutter-engineering` + `numuw-ui-ux`.
- Crashes/regressions: `numuw-debugging-tdd` + `numuw-dart-quality`.
- Supabase/Auth/RLS/Storage/Edge Functions: `numuw-supabase-backend` + `numuw-security`.
- GitHub Pages/Web preview: `numuw-webapp-testing` + `numuw-debugging-tdd`.
- Before merge: `numuw-pr-review`; add `numuw-security` for auth/data/workflow changes.

These local skills are curated from Flutter/Dart, Supabase, Matt Pocock, Anthropic, UI/UX Pro Max, Trail of Bits, and Sentry skill repositories. External skills and scripts are untrusted until reviewed. `AGENTS.md` always overrides external skill guidance when they conflict.

## Required checks

Before considering any code change complete, run:

```bash
flutter pub get
flutter analyze --no-fatal-infos
flutter test -r expanded
```

For changes that touch routing, platform configuration, dependencies, or release code, also build the relevant target when possible:

```bash
flutter build web --release \
  --dart-define=SUPABASE_URL=https://example.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_example
```

Do not mark work complete if tests fail. Do not disable, delete, or weaken tests only to make CI pass.

## Figma parity rules

- Canonical mobile viewport is 390×844, but layouts must remain responsive rather than hard-coded to that size.
- Preserve the five-tab information architecture: اليوم، التسجيل، طفلي، اسألي نُمُوّ، المزيد.
- Preserve Figma semantic Light, Dark and optional Night Logging appearance.
- Night Logging is a low-light variation of Dark and is scoped to feeding, sleep and diaper tracking only.
- Use the semantic tokens under `lib/core/theme/` and compatibility aliases in `lib/core/app_colors.dart`; do not introduce one-off hex colors unless the Figma asset itself requires them.
- Preserve radii 14/18/22/28 and gentle ~250ms screen transitions; honor Reduce Motion.
- Keep touch targets at least 48×48 where practical and preserve RTL/SafeArea behavior.
- Do not fake backend capability to satisfy visual parity. If Figma shows a control whose backend is not connected, make its limitation explicit until the real capability is implemented.

## Flutter conventions

- Keep widgets small and reusable.
- Preserve RTL behavior and test Arabic layout on small screens.
- Preserve Light and Dark themes.
- Use the existing Numuw design tokens instead of introducing ad-hoc colors and typography.
- Avoid hard-coded screen sizes; layouts must handle small phones and text scaling.
- Keep business logic out of large UI widgets when it can live in services, repositories, state, or pure helpers.
- Prefer additive/refactoring changes over wholesale rewrites unless the task explicitly requires a rebuild.

## Supabase and security

- Never commit service-role keys, secret keys, passwords, private API keys, signing certificates, or store credentials.
- Flutter clients may use only the Supabase URL and publishable key.
- Privileged AI/provider credentials belong in Supabase Edge Function secrets, never in Dart code.
- Every exposed user-data table must use RLS.
- RLS policies must enforce ownership/guardian access, not only `TO authenticated`.
- Treat migrations in `supabase/migrations/` as source-controlled production changes.
- Never edit production data or schema casually to work around a client bug.
- Request camera, photo, microphone, speech and notification permissions only at the moment a user invokes the related feature, with a truthful usage description.

## Health and child-care content

- Do not invent vaccination schedules, medical thresholds, growth standards, feeding guidance, or health claims.
- Source-gated health content must remain source-gated.
- Preserve the app's emergency escalation behavior.
- AI-generated guidance must not present itself as a diagnosis or a replacement for professional medical care.
- Changes to health datasets require tests and traceable source metadata.

## AI assistant

- The mobile app must call Supabase Edge Functions; it must not call Gemini/OpenAI directly with a secret client-side API key.
- Preserve authentication and child authorization checks.
- Keep structured response validation and safe error mapping.
- Do not remove rate limiting or emergency keyword handling without an explicit security review.
- Never claim an attachment was read by the AI unless the backend actually received and processed that attachment.

## Release identity

- Android application ID: `com.numuw.app`.
- iOS bundle ID: `com.numuw.app`.
- Product display name: `نُمُوّ`.
- Android releases must target API 36 or newer for current Google Play submission requirements.
- Production Android builds must never use debug signing.

## CI/CD

- GitHub Actions is the primary fast quality gate.
- Codemagic is the cloud builder for Android App Bundles and signed iOS IPA/TestFlight builds.
- Secrets must be stored in GitHub/Codemagic/Supabase secret stores, not repository files.
- Keep release workflows reproducible from the repository so development can be operated from a phone.

## Pull requests

Every PR should state:

1. What changed.
2. Why it changed.
3. Tests/builds run.
4. Any required external configuration or secrets.
5. Screens or flows affected.

Large PRs should be split when possible. Never silently modify unrelated business logic while doing visual work.
