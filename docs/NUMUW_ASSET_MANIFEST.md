# Numuw production asset manifest

The approved maternal design board is the visual source of truth. `flutter_svg` renders custom monochrome SVGs through `NumuwIcon`; the same artwork is recolored for Morning and Evening.

## Guaranteed production families

Navigation/identity: logo, home, quick log, child, assistant, more, profile, bell, calendar, history.

Daily care: feeding, breastfeeding right/left illustrations, bottle, formula, pumping, sleep, wake, diaper, wet/dirty diaper, food, medicine, temperature, note and timer.

Child health/development: vaccination, growth, weight, height, head circumference, milestones, activities, doctor, doctor report, prescription, PDF and charts.

Pregnancy/preparation: pregnancy, hospital bag, shopping, checklist, documents and tasks.

Mother/family: mother, water, mood, breathing, family, caregiver and child-add.

Content/commercial: article, audio, community, weekly report, premium, meal plan and source/reference.

Utilities: camera, upload, microphone, voice waveform, emergency, location, share, settings, privacy, language, logout, email, moon, edit, info, back, add, check and search.

The exact registry is `NumuwIcons.all` in `lib/widgets/icons/numuw_icon.dart`. CI loads every registered asset in `test/numuw_icon_assets_test.dart`, so a missing or incomplete SVG fails the test suite.

## Missing-asset protocol

A missing ordinary icon/illustration must not block implementation. Generate an original SVG with ChatGPT/current coding agent, follow `.github/skills/numuw-asset-generation/SKILL.md`, register it, test it, and continue. Do not ship Emoji or unrelated stock icons as the final artwork on migrated screens.

## Visual rules
- Standard viewBox: `0 0 24 24`; larger selector illustrations may use a larger viewBox.
- Thin rounded line language, usually ~1.6-1.8 stroke units at 24x24.
- Monochrome standard icons, runtime recoloring through `NumuwIcon`.
- No embedded font, remote image, raster/base64 payload, or copied copyrighted icon artwork.
- Morning uses warm porcelain/cream surfaces with Burgundy/Plum accents.
- Evening uses deep charcoal surfaces with rose/mauve accents and low-glare contrast.
- Cairo remains the UI font.

## Migration rule
Preserve production repositories/state/auth/timers/notifications and replace presentation around those contracts. Advanced functionality may move behind progressive disclosure, but it must not be deleted merely to match a simpler reference.
