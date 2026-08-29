# Numuw production migration map

The approved Classy Motherhood preview is the visual source of truth. The files under `lib/screens/` remain the source of truth for production behavior until each row below is migrated and validated.

## Status legend

- `preview-ready`: approved visual composition exists, production screen still owns behavior/UI.
- `foundation-ready`: shared design/motion/agent tooling is available for the migration.
- `production-migrated`: approved preview composition is wired to real production data/actions and verified.

## Migration waves

| Wave | Product area | Preview source | Production source | Critical contracts to preserve | Status |
|---|---|---|---|---|---|
| 0 | Design system + motion | `numuw_classy_components.dart`, preview shared files | shared widgets/theme | Light/Black, RTL, tokens, reduced motion | foundation-ready |
| 1 | Home | `design_preview/full/preview_home.dart` | `home_screen.dart` | `ChildSession`, `NumuwAppState.refreshDashboard`, `AppEvents`, family tasks, event details/edit/delete | preview-ready |
| 1 | Quick Log | `design_preview/full/preview_care_flows.dart` | `quick_log_screen.dart` | `CareEventRepository`, `NumuwAppState.saveCareEvent`, `LogTimerState`, validation, real timers | preview-ready |
| 1 | Feeding | `design_preview/full/preview_care_flows.dart` | `quick_log_screen.dart` | feeding timer, side, methods, amount, burp/vomit, notes | preview-ready |
| 1 | Sleep | `design_preview/full/preview_care_flows.dart` | `quick_log_screen.dart` | sleep timer per selected child, start/finish persistence | preview-ready |
| 1 | Pumping | `design_preview/full/preview_care_flows.dart` | `pumping_screen.dart` + quick log pane | pumping timer/session, split quantities, notes, analytics refresh | preview-ready |
| 1 | Diaper / food / medicine / temperature / note | `design_preview/full/preview_care_flows.dart` | `quick_log_screen.dart` | validation, timestamps, medical safety copy, save errors | preview-ready |
| 2 | Child profile / growth / vaccinations | `design_preview/full/preview_child_family_ai.dart` | `child_screen.dart` | selected child, growth records, vaccination state, country schedule | preview-ready |
| 2 | Family tasks / doctor questions | `design_preview/full/preview_child_family_ai.dart` | child/family production screens | ownership, completion, sharing/visibility | preview-ready |
| 2 | Pumping analytics | `design_preview/full/preview_child_family_ai.dart` | pumping production screens | real event aggregates, date windows | preview-ready |
| 3 | Assistant | `design_preview/full/preview_child_family_ai.dart` | `assistant_screen.dart` | production AI service, safety, real child context, errors | preview-ready |
| 4 | Splash / welcome / login / register / email confirmation | `design_preview/full/preview_auth_onboarding.dart` | auth + splash/welcome screens | Supabase auth/session/callback behavior | preview-ready |
| 4 | Onboarding 1–3 | `design_preview/full/preview_auth_onboarding.dart` | onboarding screens | selected child creation/update, persisted onboarding completion | preview-ready |
| 5 | Settings / Family Sharing / Weekly Share | `design_preview/full/preview_more_states.dart`, `preview_child_family_ai.dart` | `more_screen.dart`, family screens, `weekly_share_screen.dart` | permissions, family privacy, exports/share, settings persistence | preview-ready |
| 5 | Loading / Empty / Error / Success | `design_preview/full/preview_more_states.dart` | all production screens | real async/error states, retry, no demo fixtures | preview-ready |

## Required migration procedure per row

1. Read the production screen first and inventory every repository/state/service/side effect.
2. Read the matching preview composition.
3. Extract/reuse presentation components instead of copying demo logic.
4. Bind real model values and production callbacks.
5. Preserve optimistic updates, retries, validation, timers, lifecycle listeners, navigation, and error recovery.
6. Apply Numuw motion primitives only after behavior is preserved.
7. Verify Arabic RTL, Light/Black, reduced motion, narrow phones, large text, keyboard/safe-area behavior.
8. Add deterministic widget/regression coverage.
9. Run analyzer, tests, Android compile, iOS compile.
10. Mark `production-migrated` only after the production route—not the preview route—uses the approved composition.

## Release gate

The app is not considered production-ready while high-frequency production routes still depend on the legacy visual layer or when any critical flow has only a demo preview implementation. Release readiness requires waves 1–5 to be production-migrated and the production-quality workflow to pass.
