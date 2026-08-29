---
name: numuw-motion
description: Add or review premium Numuw Flutter motion and micro-interactions using the project's motion tokens, native Flutter, flutter_animate, and animations package while protecting performance and reduced-motion accessibility.
argument-hint: "[screen, component, or interaction]"
user-invocable: true
---

# Numuw motion

Use motion to explain state and hierarchy, not to decorate every element.

## Stack order

1. Native Flutter animation for direct state feedback, timers, counters, press states, and simple transitions.
2. `flutter_animate` for concise fade/slide/scale/shimmer-style entrance sequences.
3. `animations` for container transforms and fade-through changes where the relationship justifies them.
4. Do not introduce another motion package unless the requested interaction cannot be implemented cleanly with the above.

## Numuw rules

- Reuse `NumuwMotionTokens`: button 120ms, card 280ms, page 300ms, success 580ms unless the design tokens change centrally.
- Calm and reassuring. No elastic/bouncy game motion for routine maternal tracking tasks.
- Use `NumuwPressable`, `NumuwFadeSlideIn`, `NumuwAnimatedNumber`, `NumuwSuccessBloom`, `NumuwFadeThroughSwitcher`, and `NumuwOpenContainer` where appropriate.
- Respect `NumuwMotionPolicy.reduceMotion(context)`.
- Never run hidden repeating animations when the widget is offstage; use `TickerMode`/lifecycle awareness.
- Avoid animating expensive layout properties in large lists when transform/opacity can communicate the same state.
- No animation should delay logging, saving, emergency information, validation, or navigation.

Verify on low-end assumptions and ensure no controller/timer leaks.
