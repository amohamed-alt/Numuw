---
name: numuw-webapp-testing
description: Browser-level validation for Numuw Flutter Web previews. Use for GitHub Pages, runtime smoke tests, auth flows, responsive QA, and web regressions.
metadata:
  project: Numuw
  upstream:
    - anthropics/skills
---
# Numuw Web App Testing

A green `flutter build web` is not sufficient. The preview is considered healthy only when a real browser loads the published artifact and Flutter renders a view.

## Minimum smoke gate
- Serve the exact `build/web` artifact using the final base path.
- Open it in Chromium/Chrome headless.
- Fail if bootstrap reports an error.
- Fail if Flutter never attaches a rendered view.
- Capture browser stderr and DOM diagnostics on failure.
- For minified release crashes, build with source maps and resolve the generated JS location back to Dart/package code.

## GitHub Pages specifics
- Build with the repository base href (`/Numuw/`).
- Confirm `main.dart.js`, `flutter_bootstrap.js`, CanvasKit/renderer assets, fonts, icons, manifest, and package assets return successfully.
- Avoid hidden dependencies on blocked CDNs where local assets are available.
- Treat service-worker/cache behavior explicitly when changing bootstrap code.

## Critical browser journeys
When test accounts are available, validate:
1. Welcome -> sign up/sign in.
2. Email-confirmation state.
3. Add child.
4. Create care event.
5. Dashboard reflects event.
6. Assistant request returns safe success/error state.
7. Family invite acceptance.
8. Settings/theme/reduced-motion behavior.
9. Logout and session restoration.

## Responsive QA
Validate mobile widths, desktop framed preview, RTL, keyboard/form interaction, sheets, scrolling, and no horizontal overflow.

## Failure diagnostics
Keep the startup screen visible until Flutter succeeds. On bootstrap/runtime failure, show a user-readable state and log enough structured diagnostics for CI. Never publish a known-white-screen build.

## Upstream guidance incorporated
Adapted from Anthropic `webapp-testing` principles and Numuw's existing browser smoke-test experience.