# Numuw permanent production prompt

Continue Numuw as a complete production Flutter application, not a collection of mockups. Preserve all existing repositories, Supabase contracts, auth, timers, notifications, persistence, reporting, family-sharing logic and real user data. Use the approved classy motherhood reference as the visual source of truth and migrate every production flow to the shared Numuw design system.

For every screen and feature: implement Morning + Evening, Arabic-first RTL, responsive one-hand layouts, semantic accessibility, loading/empty/error/success/disabled states, calm premium animation, haptics only where useful, and regression coverage. Prefer native Flutter motion plus `flutter_animate`/`animations`; respect reduced-motion settings and avoid decorative jank.

Never stop because an icon or illustration is missing. First search `NumuwIcons` and the asset manifest. If artwork is still missing, use ChatGPT/current coding agent to create an original clean SVG in Numuw's rounded line style, save it in `assets/icons/`, register it in `NumuwIcons` + `NumuwIcons.all`, update the manifest when needed, and continue implementation. Do not ship Emoji or unrelated Material icons as final artwork on migrated screens.

Work through `docs/NUMUW_IMPLEMENTATION_MASTER.md` until all MVP product areas are production-ready. For each wave: inspect logic → implement shared presentation → wire real state/actions → add animation → verify RTL/responsiveness/accessibility → test assets/widgets → capture Morning/Evening previews where useful → run analyzer/tests/Android/iOS checks → fix failures → continue to next area.

Do not silently remove existing capabilities to match a simpler visual reference. Hide advanced fields behind progressive disclosure when needed, but preserve functionality. Never replace production data with demo data outside explicit preview routes.
