---
name: numuw-ui-ux
description: UI/UX review and implementation rules for Numuw. Use for Figma parity, visual hierarchy, accessibility, RTL, responsive behavior, and mobile interaction quality.
metadata:
  project: Numuw
  upstream:
    - nextlevelbuilder/ui-ux-pro-max-skill
    - anthropics/skills
---
# Numuw UI/UX

## Source of truth
Figma Make remains the visual source of truth. External UI skills are advisory only and must not replace Numuw's tokens, information architecture, or product decisions.

## Visual quality
- Preserve semantic Numuw tokens for background, cards, gold accent, text, radii, and motion.
- Avoid arbitrary hex values when a design token exists.
- Keep hierarchy calm and readable for tired caregivers using the app at night.
- Use progressive disclosure instead of overcrowding logging screens.
- Empty, loading, error, success, offline, permission-denied, and retry states are part of the design, not afterthoughts.

## RTL and Arabic
- Start from RTL layout logic, not mirrored LTR assumptions.
- Check icons whose meaning is directional.
- Test long Arabic labels, numbers, mixed Arabic/Latin text, and text scaling.
- Avoid clipped Arabic glyphs and overly tight line heights.

## Accessibility
- Keep meaningful contrast in Light/Dark/Night Logging modes.
- Respect Reduce Motion.
- Prefer semantic labels for icon-only controls.
- Do not communicate critical health or error state through color alone.
- Maintain practical touch targets of about 48×48.

## Mobile ergonomics
- Primary actions should be reachable and visually obvious.
- Destructive actions require deliberate confirmation.
- Avoid accidental data loss when dismissing sheets/forms.
- Timers must clearly communicate active child, start time, current state, and stop/finish action.

## Review checklist
Compare implementation with Figma at 390×844 and also test small-width and desktop-framed web preview. Check spacing, typography, radii, icon sizing, active states, bottom navigation, sheets, transitions, RTL, safe areas, keyboard overlap, and scroll reachability.

## Upstream guidance incorporated
Adapted from UI/UX Pro Max and Anthropic frontend-design guidance, constrained by Numuw's Figma design system and health-care context.