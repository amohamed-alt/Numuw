# Numuw Visual QA

This checklist is the quality gate for the visual rebuild branch.

## Master screen scope

The first visual milestone covers four reusable screens:

1. Home
2. Quick Log
3. Feeding
4. Child Profile

Each screen must render in Light and Dark mode with consistent RTL layout, warm motherhood styling, botanical identity, and reusable spacing patterns.

## Home Light and Dark checks

- Warm Arabic greeting is visible.
- Child summary card shows portrait, name, age, and favorite affordance.
- Growth plant card shows illustration, copy, and progress indicator.
- Today summary shows feeding, sleep, and diaper metric cards.
- Vaccine and daily tip cards render below the metrics.
- Bottom navigation keeps Home active.
- Light mode uses warm cream surfaces, botanical green, and gold accents.
- Dark mode uses a warm night palette, not pure black.
- No text overflow at 393 x 852.

## Quick Log checks

- Eight quick actions render in a tappable grid.
- Recent timeline shows feeding, sleep, and diaper rows.
- Layout remains easy to use one-handed.
- Light and Dark modes keep readable contrast.

## Feeding checks

- Active session state is visible.
- Timer and progress area are visually dominant.
- Side selector includes right, left, and both.
- Feeding type, quantity, burp, and spit-up fields are visible.
- Save action is visually primary.
- Light and Dark modes render without overflow.

## Child Profile checks

- Portrait, name, and age are clear.
- Core stats render in compact cards.
- Growth, vaccines, family tasks, and doctor questions render as feature rows.
- Light and Dark modes render without overflow.

## Automated check

Run:

```bash
flutter test test/numuw_master_preview_test.dart
```

Current coverage:

- Home Light smoke rendering.
- Home Dark smoke rendering.
- Navigation through the four master screens.
- Theme toggle behavior.
- Dark-mode smoke coverage for Quick Log, Feeding, and Child Profile.

## Required before merge

- Compare the four screens against the approved references on a mobile viewport.
- Capture Light and Dark screenshots for each screen.
- Replace temporary embedded bitmap artwork with final transparent vector assets.
- Run `flutter analyze` and the full test suite.
- Keep the PR as draft until visual approval is complete.
