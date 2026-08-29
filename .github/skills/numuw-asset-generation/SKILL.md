---
name: numuw-asset-generation
description: Create or extend Numuw production SVG icons and illustrations when a screen needs artwork that does not yet exist.
argument-hint: "[asset or screen needing artwork]"
user-invocable: true
---

# Numuw asset generation

Missing artwork is never a reason to stop a production migration.

1. Search `NumuwIcons` and `docs/NUMUW_ASSET_MANIFEST.md` first.
2. If the required icon/illustration does not exist, generate an original SVG in the current task. Use ChatGPT/current coding agent to design the SVG markup directly when helpful; do not wait for an external designer for ordinary vector UI artwork.
3. Save icons under `assets/icons/<snake_case>.svg`. Use a clean viewBox (normally `0 0 24 24`), rounded strokes, simple geometry, no embedded fonts, no raster/base64 payloads, and no copied copyrighted artwork.
4. Keep standard icons monochrome so `NumuwIcon` can recolor them for Morning and Evening. Larger illustrations may use a larger viewBox but must preserve the same visual language.
5. Register every production asset in `NumuwIcons` and `NumuwIcons.all` immediately.
6. Update `docs/NUMUW_ASSET_MANIFEST.md` when adding a new semantic family.
7. Run `flutter test test/numuw_icon_assets_test.dart` plus the normal analyzer/tests. A missing/broken SVG must fail CI.
8. Prefer SVG for icons and simple illustrations; use generated raster art only when a vector cannot express the required visual faithfully.

Never ship Emoji, a random Material icon, or an unrelated third-party icon as the final visual when the Numuw system calls for custom artwork. Temporary fallbacks are allowed only while a screen is explicitly marked unmigrated.
