# Numuw repository instructions

Numuw is a production Flutter motherhood application in Arabic-first RTL with Morning and Evening visual variants. The approved classy reference is the visual source of truth; the repository already contains production business logic, repositories, Supabase/auth integration, notifications, reporting and local app state.

## Non-negotiable product rules
- Preserve existing repositories, Supabase schema/contracts, auth, persistence, timers, notification behavior and real-data flows unless explicitly changing product logic.
- Migrate preview/reference UI into production screen-by-screen; demo data must never leak into production routes.
- Reuse the Numuw design system and tokens before creating near-duplicate widgets.
- Arabic/RTL is first-class; keep supported LTR valid too.
- One-hand reachability and >=44 logical pixel touch targets are required.
- Every applicable screen needs loading, empty, error, success and disabled states.
- Do not remove real capabilities just because the visual reference is simpler; use progressive disclosure.

## Permanent missing-asset rule
- Search `NumuwIcons` and `docs/NUMUW_ASSET_MANIFEST.md` before using generic artwork.
- If an icon/illustration is missing, do not stop. Use ChatGPT/current coding agent to generate an original clean SVG during the task, following `.github/skills/numuw-asset-generation/SKILL.md`.
- Save it under `assets/icons/`, register it in `NumuwIcons` and `NumuwIcons.all`, update the manifest when needed, and continue implementation.
- Migrated production screens must not ship Emoji or unrelated Material icons as final artwork when a Numuw asset can represent the concept.
- `test/numuw_icon_assets_test.dart` is mandatory protection: every registered asset must load as a complete SVG.

## Motion
- Calm, reassuring and premium; never game-like.
- Use `NumuwMotionTokens`; native Flutter for direct state feedback, `flutter_animate` for concise entrances/micro-interactions, and `animations` for meaningful transitions.
- Respect `MediaQuery.disableAnimations`; decorative motion disappears under reduced motion.
- Do not add Rive/Lottie/Flame unless a concrete interaction genuinely requires it.

## Engineering quality
- Prefer small reusable widgets and avoid async work/repeated calls from `build`.
- Dispose controllers/subscriptions/timers.
- Keep secrets/service-role credentials out of the client/repository.
- Run format, analyze and tests; UI waves also keep Android+iOS builds healthy and capture Morning/Evening previews for major screens.
- Scan Arabic literals for encoding corruption/mojibake when touching legacy files; never ship `Ã`/`Â`-style broken text.

## Delivery loop
Use `.github/skills/numuw-autonomous-builder/SKILL.md` and `docs/NUMUW_IMPLEMENTATION_MASTER.md`. Continue through unchecked MVP areas rather than stopping at a single mockup: inspect logic -> implement shared production presentation -> wire real state/actions -> add motion -> verify RTL/responsiveness/accessibility -> test -> capture previews -> Android/iOS check -> fix -> continue.

Default sequence: Home -> Quick Log -> Feeding/Sleep/Pumping -> Child/Growth/Vaccinations -> Assistant -> Auth/Onboarding/Pregnancy -> Family/Mother -> Content -> Settings/Commercial -> remaining secondary flows.
