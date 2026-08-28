# Numuw Agent Skill Registry

This repository uses a curated local skill set under `.agents/skills/`. The goal is to capture the strongest relevant practices from popular/open agent-skill repositories without allowing conflicting or unsafe third-party instructions to override Numuw's product contract.

`AGENTS.md` is always the highest-priority repository instruction. Figma remains the visual source of truth. Supabase migrations/production authorization model remain the backend source of truth.

## Installed local skills

| Skill | Use for | Upstream inspiration |
|---|---|---|
| `numuw-flutter-engineering` | Flutter architecture, layout, routing, localization, API/JSON, widget/integration testing | `flutter/agent-plugins`, `dart-lang/skills` |
| `numuw-dart-quality` | runtime errors, analysis, unit tests, mocks, coverage, dependency conflicts | `flutter/agent-plugins`, `dart-lang/skills` |
| `numuw-supabase-backend` | schema, migrations, RLS, Auth, Storage, Edge Functions, Postgres performance | `supabase/agent-skills` |
| `numuw-debugging-tdd` | evidence-first debugging, TDD, regression tests, architecture improvements | `mattpocock/skills` |
| `numuw-ui-ux` | Figma parity, responsive mobile UX, accessibility, RTL | `nextlevelbuilder/ui-ux-pro-max-skill`, `anthropics/skills` |
| `numuw-webapp-testing` | GitHub Pages/browser runtime validation and critical web journeys | `anthropics/skills` |
| `numuw-security` | auth/data security, insecure defaults, differential/static review, GHA security | `trailofbits/skills`, `getsentry/skills` |
| `numuw-pr-review` | bug finding, PR iteration, CI/release review, external skill scanning | `getsentry/skills` |

## Upstream skill families incorporated

### Flutter / Dart
- flutter-add-integration-test
- flutter-add-widget-test
- flutter-add-widget-preview
- flutter-apply-architecture-best-practices
- flutter-build-responsive-layout
- flutter-fix-layout-issues
- flutter-implement-json-serialization
- flutter-setup-declarative-routing
- flutter-setup-localization
- flutter-use-http-package
- dart-add-unit-test
- dart-collect-coverage
- dart-fix-runtime-errors
- dart-generate-test-mocks
- dart-resolve-package-conflicts
- dart-run-static-analysis

### Supabase
- supabase-postgres-best-practices
- Supabase Auth/RLS/Storage/Edge Function operational guidance

### Debugging / engineering method
- diagnosing-bugs
- tdd
- code-review
- improve-codebase-architecture

### UI / browser testing
- UI/UX Pro Max design-system/mobile UX guidance
- Anthropic frontend-design guidance
- Anthropic webapp-testing guidance

### Security / review
- insecure-defaults
- static-analysis
- differential-review
- sharp-edges
- property-based-testing
- find-bugs
- security-review
- gha-security-review
- iterate-pr
- skill-scanner

## Activation guidance

- Any Flutter UI/feature change: `numuw-flutter-engineering` + `numuw-ui-ux`.
- Crash/regression: `numuw-debugging-tdd` + `numuw-dart-quality`.
- Supabase/Auth/RLS/Storage/Edge Function: `numuw-supabase-backend` + `numuw-security`.
- GitHub Pages/Web preview: `numuw-webapp-testing` + `numuw-debugging-tdd`.
- Before merge: `numuw-pr-review`; add `numuw-security` for auth/data/workflow changes.

## Rule priority

1. Platform/system safety requirements.
2. `AGENTS.md` repository contract.
3. Current task acceptance criteria.
4. Relevant local Numuw skills.
5. Upstream/general advice.

If an upstream recommendation conflicts with Numuw's Figma design, verified health-safety behavior, Supabase authorization, or store requirements, do not apply it blindly; document the reason and preserve the higher-priority requirement.