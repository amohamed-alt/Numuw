---
name: numuw-responsive
description: Audit and adapt Numuw Flutter UI for real Android/iOS phone widths, safe areas, keyboard, text scaling, RTL/LTR, and orientation constraints without turning the mobile product into a desktop layout.
argument-hint: "[screen or flow]"
user-invocable: true
---

# Numuw responsive mobile review

Numuw is phone-first. Optimize for compact and large phones rather than adding desktop complexity.

- Test narrow widths around 320–360 logical pixels and common 390–430 widths.
- Avoid fixed heights around Arabic text, validation, cards, or buttons unless the content is guaranteed.
- Use Wrap/flexible layout when labels can grow; prevent RenderFlex overflow.
- Keep primary actions reachable above system navigation and keyboard insets.
- Respect SafeArea and bottom-sheet/modal insets.
- Preserve meaningful RTL ordering and directional padding/alignment.
- Verify increased system text scale does not hide required actions or critical information.
- For grids, adapt aspect ratio/column behavior instead of shrinking text below readable sizes.
- Keep horizontal quick-action rows intentionally scrollable when fitting all actions would create cramped targets.
- Landscape/tablet support may improve naturally, but do not redesign the app for desktop unless explicitly requested.

Add a focused widget/regression test for any responsive bug corrected.
