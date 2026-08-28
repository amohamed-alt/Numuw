---
name: numuw-rtl-accessibility
description: Audit and fix Numuw Flutter screens for Arabic RTL, text scaling, semantics, touch targets, reduced motion, keyboard/safe-area behavior, and light/black contrast without changing business logic.
argument-hint: "[screen or flow]"
user-invocable: true
---

# Numuw RTL and accessibility audit

For the target flow:

1. Test Arabic RTL first, then LTR if the route supports it.
2. Replace left/right-specific layout choices with directional equivalents where meaning is directional rather than physical.
3. Verify long Arabic text and increased text scale do not clip, overlap, or force important actions off-screen.
4. Ensure interactive targets are at least 44 logical pixels and have meaningful semantic labels.
5. Confirm focus/keyboard flow for forms and that validation is understandable without relying on color alone.
6. Respect system reduced-motion via `NumuwMotionPolicy` / `MediaQuery.disableAnimations`.
7. Check contrast in both Light and Black variants and avoid low-contrast disabled/error states.
8. Keep bottom navigation, sheets, timers, and primary logging actions safe from system insets.
9. Do not hide medically relevant warnings or critical actions behind gestures only.
10. Add regression coverage for any accessibility bug fixed.
