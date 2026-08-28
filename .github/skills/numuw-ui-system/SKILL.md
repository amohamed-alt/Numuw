---
name: numuw-ui-system
description: Build or refactor Numuw Flutter UI using the approved classy design system, shared components, light/black variants, Arabic-first RTL, responsive mobile constraints, and consistent loading/empty/error/success states.
argument-hint: "[screen or component]"
user-invocable: true
---

# Numuw UI system

- Inspect `lib/widgets/numuw_classy_components.dart`, `lib/widgets/numuw_components.dart`, current theme/tokens, and the approved design preview before writing new UI.
- Reuse shared surfaces, buttons, metrics, identity blocks, quick actions, segmented controls, timelines, and navigation primitives.
- Never fork a near-identical button/card just to change spacing or color; extend the shared API when the pattern is genuinely reusable.
- Keep Light and Black variants coherent and verify contrast.
- Arabic is the primary content direction. Use directional padding/alignment and avoid assumptions tied to left/right.
- Keep layouts comfortable on narrow phones and large text. Avoid fixed heights around variable Arabic copy.
- Primary logging actions must stay reachable and visually dominant without clutter.
- Build explicit loading, empty, error, success, and disabled states for production screens.
- Decorative illustration must never replace real controls or text.
- Maintain semantic labels and at least 44 logical pixel touch targets.

Do not modify data/repository behavior unless explicitly required by the task.
