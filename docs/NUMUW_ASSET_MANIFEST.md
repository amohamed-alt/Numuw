# Numuw production asset manifest

The approved maternal design board is the visual source of truth for production UI. Generic Material icons are allowed only as temporary fallbacks in non-migrated screens.

## Vector runtime

- Package: `flutter_svg`
- Wrapper: `lib/widgets/icons/numuw_icon.dart`
- Asset root: `assets/icons/`
- Icons are monochrome SVG and recolored at runtime for Morning and Evening themes.

## Custom icon family

| Asset | Primary use |
| --- | --- |
| `logo_mark.svg` | Numuw mark, splash, child placeholder |
| `home.svg` | Home navigation |
| `quick_log.svg` | Quick Log navigation |
| `child.svg` | Child navigation/profile |
| `assistant.svg` | Assistant navigation |
| `more.svg` | More navigation / overflow |
| `feeding.svg` | Feeding metric and quick action |
| `feeding_right.svg` | Right-side breastfeeding selector illustration |
| `feeding_left.svg` | Left-side breastfeeding selector illustration |
| `pumping.svg` | Pumping quick action |
| `sleep.svg` | Sleep metric and quick action |
| `diaper.svg` | Diaper metric/action |
| `food.svg` | Food quick action |
| `medicine.svg` | Medication quick action |
| `temperature.svg` | Temperature action |
| `vaccination.svg` | Vaccination metric/screens |
| `bell.svg` | Notifications utility |
| `calendar.svg` | Calendar utility |
| `profile.svg` | Profile utility |
| `history.svg` | History/refresh utility |

## Visual rules

- Stroke family: thin rounded line artwork, approximately 1.6 logical units at 24x24. Larger selector illustrations preserve the same rounded stroke language at their native viewBox.
- Primary accent: Burgundy/Plum from `AppColors.plum`.
- Morning: warm porcelain/cream surfaces, restrained borders and shadows.
- Evening: deep charcoal surfaces with rose/mauve accent, low-glare contrast.
- Cairo is the UI font.
- Bottom navigation uses the same vector artwork in both themes.
- Home composition follows the reference board: centered child identity, four compact metrics in one row, six circular quick actions, compact recent-activity timeline.
- Feeding composition follows the reference board: Natural/Formula segmented control, visual right/left side cards, compact centered timer and Burgundy primary action. Existing advanced feeding fields remain available as secondary details rather than being removed.
- Do not substitute a stock icon for a custom Numuw icon when the asset exists.

## Migration rule

When migrating a production screen, preserve repository/state/auth/timer behavior and replace presentation only. Add new custom artwork to this manifest rather than importing a second icon pack.
