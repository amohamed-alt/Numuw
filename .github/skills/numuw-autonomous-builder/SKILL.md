---
name: numuw-autonomous-builder
description: Continue building Numuw end-to-end across all product screens, features, motion, assets, themes, tests, and production wiring without stopping at mockups.
argument-hint: "[continue | feature | screen]"
user-invocable: true
---

# Numuw autonomous production builder

Treat `docs/NUMUW_IMPLEMENTATION_MASTER.md` as the delivery checklist and the approved classy reference as the visual truth.

For every work wave:
1. Inspect existing repositories/state/services first and preserve real business logic.
2. Build the production UI, not only a design preview.
3. If any icon/illustration is missing, invoke the Numuw asset-generation protocol: create an original SVG with ChatGPT/current agent, register it, test it, and continue. Do not stop to ask for an ordinary UI icon.
4. Add calm premium motion using `NumuwMotionTokens`, native Flutter, `flutter_animate`, and `animations` where appropriate. Respect reduced motion.
5. Support Morning and Evening from the same components/assets.
6. Make Arabic RTL primary, one-hand friendly, responsive, accessible, and safe for larger text.
7. Preserve/loading/empty/error/success/disabled/offline states where applicable.
8. Add widget/regression tests and visual previews for major migrated screens.
9. Run analyzer + tests + Android compile + iOS compile. Fix regressions before moving on.
10. Continue to the next unchecked production area in the master checklist instead of stopping after one pretty screen.

Product safety is non-negotiable: the AI assistant does not diagnose, prescribe, change doses, declare a child safe, or delay emergency care. Medication screens organize clinician-entered instructions only.
