---
name: numuw-ui-system
description: Build or refactor Numuw Flutter UI from the approved maternal reference board using custom Numuw SVG icons, Morning/Evening themes, Cairo typography, Arabic-first RTL, and the production component library.
argument-hint: "[screen or component]"
user-invocable: true
---

# Numuw UI system

The approved maternal design board is the visual source of truth. Do not reinterpret it into a generic dashboard aesthetic.

- Read `docs/NUMUW_ASSET_MANIFEST.md`, `lib/widgets/icons/numuw_icon.dart`, `lib/core/app_colors.dart`, current theme/tokens, and the approved preview before writing UI.
- Reuse `NumuwIcon` and existing assets under `assets/icons/`. Do not replace an available Numuw asset with a Material icon.
- New core icons must follow the Numuw family: thin rounded line SVG, consistent stroke, no stock-icon look. Add new assets to the manifest.
- Preserve the reference composition: warm editorial motherhood spacing, centered child identity, restrained cards, soft borders/shadows, Burgundy/Mauve primary accent, pastel semantic accents.
- Morning and Evening use the same layout and icon geometry; only theme tokens and runtime recoloring change.
- Reuse shared surfaces, buttons, metrics, quick actions, segmented controls, timelines and navigation primitives.
- Never fork a near-identical button/card just to change spacing or color; extend the shared API when a pattern is reusable.
- Arabic is primary. Use directional padding/alignment and avoid left/right assumptions.
- Keep layouts comfortable on narrow phones and large text. Avoid fixed heights around variable Arabic copy unless the reference requires a compact fixed visual tile.
- Primary logging actions must stay reachable and visually dominant without clutter.
- Build explicit loading, empty, error, success and disabled states for production screens.
- Decorative illustration must never replace real controls or text.
- Maintain semantic labels and at least 44 logical pixel touch targets.
- Validate migrated screens in Morning and Evening mode and capture regression screenshots.

Do not modify data/repository/auth/timer behavior unless explicitly required by the task.
