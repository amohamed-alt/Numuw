---
name: numuw-performance
description: Review Numuw Flutter code for frame smoothness, unnecessary rebuilds, animation cost, list efficiency, async misuse, image cost, timer/controller leaks, and mobile startup/runtime regressions.
argument-hint: "[screen, flow, or diff]"
user-invocable: true
---

# Numuw performance review

- Identify rebuild boundaries and keep frequently changing timers/counters from rebuilding full screens.
- Keep async work out of `build`; cache or memoize stable work at the correct layer.
- Dispose controllers, subscriptions, streams, timers, and focus/text controllers.
- Do not keep decorative tickers active offstage; use `TickerMode` and lifecycle-aware behavior.
- Prefer transform/opacity animation over expensive repeated layout/paint where equivalent.
- Avoid large unbounded widget trees and eagerly-built long lists.
- Reuse const widgets where useful, but do not perform noisy const-only refactors without measurable value.
- Check chart/data transformations for repeated O(n) work on every frame.
- Ensure network/storage calls are not triggered repeatedly by rebuilds.
- Keep animation dependencies minimal. Do not add a new package for an effect already supported by native Flutter, `flutter_animate`, or `animations`.

Run analyzer/tests and relevant Android/iOS build checks after performance edits.
