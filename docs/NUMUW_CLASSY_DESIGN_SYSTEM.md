# Numuw — Classy Motherhood Design System

This document is the implementation source of truth for the `design/classy-motherhood-v1` preview branch.

## Product personality

Numuw should feel **calm, caring, intelligent, trustworthy, warm, precise and premium**. It is designed for a parent who may be tired, holding a baby with one hand, logging an event at night, or quickly checking what happened during the day.

The system is intentionally **not** a childish baby app, a hospital UI, a generic health dashboard, or an AI/SaaS template.

## Visual language

### Light

- Background: warm porcelain `#FBF7F5`
- Surface: `#FFFDFC`
- Primary / rosewood: `#9D4F72`
- Deep rosewood: `#71384F`
- Blush: `#EFCFD1`
- Champagne: `#EAD6B8`
- Sage: `#A9BBAA`
- Lavender: `#CBBBD5`
- Powder blue: `#B7CED8`
- Main text: `#2A2427`

### Black edition

- Background: `#0F1012`
- Surface: `#17181C`
- Raised surface: `#26272D`
- Border: `#34343B`
- Primary accent: `#D7A3B6`
- Strong accent: `#E1B0C0`
- Main text: `#F8F2F3`

Night mode is a true low-glare black system, not a darkened version of the light beige palette.

## Typography

Font family: **Cairo**.

Use fewer weights and let spacing create hierarchy:

- Display: 32 / 800
- Headline: 26 / 800
- Page title: 22 / 800
- Section title: 17 / 700
- Body: 14–16 / 500
- Labels: 12–14 / 700

Avoid using weight 900 everywhere. Premium Arabic UI depends on rhythm and whitespace more than aggressive bold text.

## Spacing

Use the tokens in `AppColors.NumuwSpacing`:

- 4, 6, 10, 14, 18, 24, 32
- Page horizontal padding: 20
- Minimum touch target: 48
- Target mobile width: 390
- Maximum preview width: 430

## Radius

- Compact: 12
- Inputs: 15
- Buttons: 17
- Cards: 20
- Large cards: 26
- Hero surfaces: 30
- Pill: 999

The system does not round every object excessively. Hero and high-emotion surfaces receive the largest radii; utility controls stay tighter.

## Buttons

`NumuwClassyButton` supports:

- `primary`: default product action
- `secondary`: outlined/surface action
- `tonal`: quiet secondary action
- `danger`: destructive action only
- `black`: editorial black button for premium moments

Sizes:

- small 44px
- medium 48px
- large 54px

Example:

```dart
NumuwClassyButton(
  label: 'حفظ التسجيل',
  onPressed: save,
)
```

Black variant:

```dart
NumuwClassyButton(
  label: 'متابعة',
  variant: NumuwButtonVariant.black,
  onPressed: next,
)
```

## Core components

File: `lib/widgets/numuw_classy_components.dart`

### `NumuwClassySurface`
General premium surface. Use for grouped content, timeline sections and compact settings blocks.

### `NumuwChildIdentity`
Child identity hero. Use near the top of Home, Child and selected-child experiences.

### `NumuwMetricTile`
One clear metric. Do not place long descriptions inside metrics.

### `NumuwQuickAction`
One-handed daily logging action. Keep the icon familiar and the label to one line.

### `NumuwSectionLabel`
Section heading with optional subtitle/action.

### `NumuwSegmentedControl`
Two-to-four mutually exclusive choices.

### `NumuwTimelineRow`
Chronological care activity. Use a thin timeline instead of turning every event into a separate card.

### `NumuwBottomBarPreview`
Reference implementation for the new bottom-nav visual language.

## Motion system

File: `lib/widgets/numuw_motion_widgets.dart`

Motion must explain state, not decorate the interface.

| Token | Duration | Use |
|---|---:|---|
| instant | 90ms | tiny state response |
| button | 120ms | press feedback |
| chip | 160ms | selection |
| card | 280ms | content entrance |
| page | 300ms | screen transition |
| bottomSheet | 320ms | modal sheet |
| success | 580ms | saved-log confirmation |
| celebration | 760ms | rare milestone only |

### `NumuwPressable`
Subtle `0.985` press scale. No springy game-like bounce.

### `NumuwFadeSlideIn`
Default card/section entrance.

### `NumuwPulseDot`
Only for genuinely active timers/sessions.

### `NumuwAnimatedNumber`
For quantities, metrics and changing chart summaries.

### `NumuwSuccessBloom`
A restrained success confirmation for completed logs.

### `numuwPageRoute`
Fade + tiny horizontal movement for custom transitions.

## UX rules

1. A common care event should be loggable in seconds.
2. Primary actions stay within comfortable thumb reach where possible.
3. Important text must remain readable at night without high-contrast glare.
4. Never rely on color alone for a health/system state.
5. Avoid cards inside cards unless hierarchy genuinely requires it.
6. Use timeline/list grouping for repeated activity, not repeated large cards.
7. Health-related warnings use direct language without panic-inducing visuals.
8. Arabic RTL is the primary layout direction, not a mirrored afterthought.
9. Keep destructive actions visually separated from routine care actions.
10. Animation is reduced in frequency when the user is performing repetitive logging.

## Preview

Run the design lab without changing production routing:

```bash
flutter run -d chrome --dart-define=DESIGN_PREVIEW=true
```

Or build it:

```bash
flutter build web --dart-define=DESIGN_PREVIEW=true
```

The gallery contains:

- Brand foundations
- Classy Home light
- Classy Home black
- Quick Log concept
- Component library
- Motion lab

## Migration strategy

The branch first updates global palette/theme tokens so current screens inherit the new mood without altering repositories, Supabase logic or care-event behavior. New premium components are then available for screen-by-screen migration.

Recommended screen order:

1. Home
2. Quick Log / Feeding / Sleep / Pumping
3. Child / Growth / Vaccinations
4. Assistant
5. More / Family sharing
6. Welcome / Auth / Onboarding
7. Weekly share card

All production data logic should remain unchanged during the visual migration.
