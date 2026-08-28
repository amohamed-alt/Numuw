# Numuw AI Engineering Rules

This file is the operating contract for AI coding agents working in this repository.

## Product

Numuw (نُمُوّ) is an Arabic-first motherhood and child-care application built with Flutter and Supabase. Arabic RTL is a first-class experience, not a translation layer added later.

## Source of truth

- Stable base: `main`.
- Current product redesign: `numuw-redesign` until it is formally merged.
- Never merge a large visual or data-layer change directly into `main`.
- Work in a focused branch and open a pull request.

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
