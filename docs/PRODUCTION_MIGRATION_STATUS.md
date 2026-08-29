# Numuw production redesign status

This file is the handoff checkpoint for the Classy Motherhood production migration.

## Done

- Full design-preview layer remains available for visual exploration.
- Shared design system and motion tokens are in place.
- Open-source motion dependencies are intentionally limited to `flutter_animate` and Flutter-team `animations`.
- Repository-level Copilot instructions and Numuw skills are installed under `.github/`.
- Production bottom navigation now uses the Classy visual language and the existing tab/state model.
- Home presentation is shared between design preview and production.
- Production Home reads the real selected child and `DashboardSummary` from the existing state/repository layer.
- Home quick actions route into the existing production logging tab; child/vaccination actions route into the existing production child tab.
- Loading/error states exist for the migrated production Home.
- Widget coverage checks the shared Home in Light and Dark on a 430px phone surface.
- CI checks analyze/tests, Web preview screenshot, Android debug compile and iOS no-codesign compile.

## In progress / next

1. Quick Log launcher and care-flow presentation migration while preserving `CareEventRepository`, `NumuwAppState` and `LogTimerState`.
2. Feeding / Sleep / Pumping detailed views.
3. Child overview, growth and vaccinations.
4. Assistant.
5. Auth and onboarding.
6. Family sharing / weekly share / settings.
7. Golden or screenshot regression coverage for Light and Black variants.

## Non-negotiable migration rule

The preview is the visual source of truth. Production repositories, Supabase/auth contracts, persistence, timers, notifications and real-data behavior are the functional source of truth. A migration may change presentation but must not replace real data with demo data or bypass existing domain logic.
