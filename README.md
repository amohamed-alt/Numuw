# نُمُوّ | Numuw

Arabic-first motherhood and child-care application built with Flutter and Supabase.

## Current development status

- Production redesign branch: `numuw-redesign`.
- Flutter targets: Android, iOS, Web.
- Backend: Supabase Auth, Postgres/RLS, Storage, Edge Functions.
- AI assistant: routed through Supabase Edge Functions; provider secrets stay server-side.
- Automated Flutter analysis and tests are already part of the repository.
- Phone-only build/release infrastructure is documented and configured in this repository.

## Local / cloud configuration

The Flutter client expects:

- `SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY`

Example local config is available in `config/dev.example.json`. Never commit production secrets.

Example run:

```bash
flutter run --dart-define-from-file=config/dev.json
```

## Required quality checks

```bash
flutter pub get
flutter analyze --no-fatal-infos
flutter test -r expanded
```

AI agents must also follow [`AGENTS.md`](AGENTS.md).

## Phone-only development and release

See [`docs/PHONE_ONLY_RELEASE.md`](docs/PHONE_ONLY_RELEASE.md) for the full workflow covering:

- GitHub Mobile / browser development flow.
- GitHub Actions quality checks.
- Flutter Web preview.
- Phone-generated Android upload keystore.
- Codemagic Android AAB/APK builds.
- Google Play Internal distribution.
- Codemagic iOS signing and TestFlight.
- Required secrets and account setup.

## Application identity

- Android application ID: `com.numuw.app`
- iOS bundle ID: `com.numuw.app`
- Display name: `نُمُوّ`
- Dart package name remains the legacy internal `flutter_application_1` for compatibility with the existing test/import surface; this does not affect store identity.

## CI/CD

### GitHub Actions

- `Phone-first quality gate`: analyze, tests, web build, Android debug build.
- `Deploy mobile web preview`: builds Flutter Web and deploys through GitHub Pages when configured.
- `Generate Android upload keystore`: one-time phone-friendly signing-key generation workflow.

### Codemagic

`codemagic.yaml` contains:

- `numuw-android-build`
- `numuw-android-play-internal`
- `numuw-ios-testflight`

## Security

Never commit:

- Supabase service-role/secret keys.
- AI provider keys.
- Android signing keys/passwords.
- Apple private keys/certificates.
- Google Play service-account credentials.

Use GitHub Secrets, Codemagic secret groups, and Supabase secrets.

## Release policy

Pull requests must pass automated checks before merge. Health, vaccination, growth, or AI guidance content must remain traceable to source metadata and must not be invented to satisfy UI requirements.
