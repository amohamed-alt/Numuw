# Numuw Production Readiness

Last audited: 2026-08-28

This file is a release gate, not a marketing checklist. A box is checked only when the repository or production service currently supports it.

## Core application

- [x] Arabic-first RTL shell and five-tab navigation.
- [x] Child onboarding and selected-child session state.
- [x] Care-event logging models/repositories and timer state.
- [x] Dashboard/weekly calculations covered by unit/widget tests.
- [x] Family sharing database model and invite acceptance RPC.
- [x] Doctor questions/reports and vaccination/growth data models.
- [x] Light/Dark/reduced-motion preferences.
- [x] Offline care-event queue support.
- [x] Browser startup smoke gate prevents known white-screen builds.
- [ ] Complete manual/device QA against the final Figma source on small Android, large Android and iPhone-class devices.
- [ ] Exact final typography/assets/store screenshots approved.

## Authentication and privacy

- [x] Supabase sign up/sign in/email confirmation/reset/update flows.
- [x] RLS enabled on user-facing application tables.
- [x] Private child-document storage policies.
- [x] In-app permanent account-deletion entry point.
- [x] Server-side `delete-account` Edge Function uses caller JWT and server-only admin privileges.
- [x] Shared-child deletion flow avoids blindly cascading away the family child record when another eligible editor exists.
- [x] Public external account-deletion page (`web/delete-account.html`).
- [x] Public privacy policy (`web/privacy.html`).
- [x] Public terms (`web/terms.html`).
- [ ] Supabase Auth leaked-password protection enabled in project dashboard.
- [ ] Dedicated public support email/support channel confirmed.

## AI assistant

- [x] Client calls Supabase Edge Functions rather than exposing provider secrets.
- [x] `ai-assistant` requires JWT.
- [x] `ai-assistant-chat` requires JWT, reads server-trusted child/events through caller RLS, rate limits requests and handles emergency keywords.
- [x] AI usage logging excludes full prompt content.
- [ ] Assistant document attachment is actually uploaded and processed by the AI. Current UI intentionally blocks sending a locally selected attachment until this is connected.
- [ ] Live authenticated AI journey verified with a dedicated test account after final release candidate is built.

## Supabase source control

- [x] Production project is active and application RLS/security helpers are hardened.
- [x] Current production advisor has no known application-table RLS warnings.
- [ ] Repository migration history is reconciled with the full production migration ledger. Production contains older migrations not currently present in Git history; do not fake this with empty migrations.
- [ ] Fresh-database rebuild from repository migrations is proven in an isolated environment.

## Web preview

- [x] GitHub Pages enabled.
- [x] Correct `/Numuw/` base path.
- [x] CanvasKit served locally with browser-compatible fallback.
- [x] Passkeys web JS bridge loaded before Flutter plugin registration.
- [x] Runtime browser smoke test verifies a Flutter view renders.
- [x] External deletion/privacy/terms static pages exist in web source.
- [ ] Latest feature commit deployed and manually checked after each release-candidate milestone.

## Android

- [x] Application ID `com.numuw.app`.
- [x] `targetSdk = 36` and `compileSdk = 37`.
- [x] Java/Kotlin 17 setup.
- [x] No debug-signing fallback for a production release.
- [x] Stale `com.example.flutter_application_1` activity removed.
- [ ] Final production keystore configured in Codemagic.
- [ ] Google Play Console app exists for `com.numuw.app`.
- [ ] Play signing/service-account credentials configured.
- [ ] Internal testing AAB uploaded and installed from Google Play.
- [ ] Data Safety form completed using actual Numuw data practices.
- [ ] Privacy Policy and Account Deletion URLs entered in Play Console.

## iOS

- [x] Intended bundle ID `com.numuw.app` documented in project contract.
- [x] Required camera/photo/microphone/speech permission descriptions exist in iOS project configuration where relevant.
- [ ] Apple Developer/App Store Connect app and bundle identifier created.
- [ ] App Store Connect API key/team configuration added to Codemagic.
- [ ] Signed IPA/TestFlight build installed on a real device.
- [ ] App Privacy questionnaire completed from actual data practices.
- [ ] Privacy/support URLs entered in App Store Connect.

## Premium purchases

- [ ] Google Play subscription products created.
- [ ] App Store subscription products created.
- [ ] Product IDs finalized and identical to application configuration.
- [ ] Seven-day introductory trial configured in the stores if the product will advertise it.
- [ ] Store purchase SDK connected to the Premium screen.
- [ ] Server-side purchase verification/entitlement persistence implemented and tested.
- [ ] Restore purchases tested on both platforms.

The current Premium screen is intentionally not treated as a working payment flow until the store products and verification path exist. Do not advertise a live trial or paid entitlement in a production build before this section is complete.

## CI/CD

- [x] GitHub Actions runs analyze/tests/web build.
- [x] Browser runtime failure blocks Pages deployment.
- [x] Codemagic workflows exist for QA, Android release and iOS release.
- [ ] Production signing/Store secrets configured in Codemagic secret groups.
- [ ] Release candidate passes Android + iOS signed cloud builds from the exact reviewed commit.

## External inputs required from the project owner

1. **Google Play Developer account/app access** for `com.numuw.app`.
2. **Apple Developer + App Store Connect access** for `com.numuw.app`.
3. **Premium decision:** confirm monthly/annual prices and 7-day trial. Suggested stable product IDs can be defined before product creation.
4. **A public support email or durable support URL** that can be placed in both stores and the privacy/support page.
5. **A dedicated test-account email that the owner can access** for email confirmation and the final end-to-end journey. The password should remain private; the owner can perform credential entry in the live preview/device build.
6. Final approval/asset source for app icon and store screenshots if the current Figma assets are not final.

## Definition of “100% working”

For this project, 100% means: critical journeys work on real Android/iOS builds; authentication, authorization, deletion, storage and AI are verified against production; purchase/restore are verified through both stores; privacy/delete/support URLs are public; signed release builds pass; and there are no known blocker-level CI, security or runtime failures. A green Flutter compile alone is not sufficient.
