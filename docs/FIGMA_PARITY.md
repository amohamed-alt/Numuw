# Numuw Figma parity map

## Visual source of truth

- Figma Make file key: `iqGCXUtDntKrQ13WTC3TYp`
- Project: `Utilize Provided Prompt`
- URL: https://www.figma.com/make/iqGCXUtDntKrQ13WTC3TYp/Utilize-Provided-Prompt
- Canonical design viewport: 390 × 844.

The Flutter application must preserve production business logic while matching this Figma source visually and behaviorally.

## Core visual system

### Dark — Moonlight Nursery

- Background: `#0F1923`
- Deep background: `#0B1119`
- Surface: `#172130`
- Elevated surface: `#1D283A`
- Primary gold: `#E8B86D`
- Primary text: `#F7F3EA`
- Secondary text: `#AAB4BE`
- Muted text: `#74808D`
- Border: `#263342`
- Success: `#79B89C`
- Warning/coral: `#D98C7C`
- Information/blue: `#7FA9C4`

### Light

- Background: `#F7F3EA`
- Deep background: `#EFE8DC`
- Surface: `#FFFDFC`
- Elevated surface: `#FFFFFF`
- Primary gold: `#B98235`
- Primary text: `#18222D`
- Secondary text: `#607080`
- Muted text: `#87919A`
- Border: `#DDD5C8`
- Success: `#4F8E73`
- Warning/coral: `#B96658`
- Information/blue: `#557F9A`

### Night Logging

Low-light variation applied only when Dark + Night Logging are enabled and the user is inside feeding, sleep, or diaper tracking.

- Background: `#090E15`
- Deep background: `#060A10`
- Surface: `#0E151F`
- Elevated surface: `#121B27`
- Gold: `#C9A063`
- Text: `#DAD4C7`
- Secondary text: `#8B95A0`
- Muted text: `#5E6A76`
- Border: `#1B2531`

### Shape and motion

- Small radius: 14
- Medium radius: 18
- Large radius: 22
- Extra large radius: 28
- Screen transition target: ~250 ms, ease-out
- Theme transition target: ~450 ms
- Reduce Motion must disable/minimize decorative transitions.

## Main navigation

1. اليوم
2. التسجيل — center quick-log action
3. طفلي
4. اسألي نُمُوّ
5. المزيد

Tab state must remain mounted while switching. Quick Log opens as a bottom sheet and then a focused logging screen.

## Implemented parity foundation

- Semantic Light/Dark/Night Logging tokens.
- Exact radius tokens.
- Figma-style tab fade/slide transitions.
- Reduced-motion preference.
- System/Light/Dark appearance selection.
- Night Logging preference.
- Offline connection banner.
- Arabic speech-to-text service with runtime permission request.
- Assistant composer with microphone, file selector, and explicit attachment state.
- Secure local storage wrapper.
- Optional Sentry observability with PII disabled by default.
- Document/image selection services.
- Universal/app-link service foundation for family invitations.
- Modern Flutter SVG, skeleton, caching, visual-testing and E2E packages.

## Deliberately not faked

### AI attachments

The current `ai-assistant-chat` Edge Function accepts text/context only. Files can be selected locally, but the UI explicitly labels them as not sent to the assistant. Full attachment support requires a protected Supabase Storage flow, RLS/guardian authorization, type/size validation, and explicit Gemini multimodal processing.

### Account deletion

The Figma screen exists, but production deletion must be implemented against the real Supabase project so auth identity, mother profile, family relationships, child ownership and retained/shared records are handled safely.

### Store subscriptions

Premium visuals exist, but real Apple/Google subscriptions remain disabled until App Store Connect and Google Play Console accounts/products exist.

### Family deep-link domain

The app-link listener exists. Native universal-link/domain association must wait until the production Numuw domain is chosen.

## Release parity gate

Before a visual change is merged into `numuw-redesign`:

- `flutter analyze --no-fatal-infos`
- full `flutter test`
- Flutter Web release build
- Android debug build
- verify Arabic RTL on narrow screens
- verify Light and Dark
- verify permissions are requested only from the feature that needs them
- no secrets in client code
- no medical content invented for visual completeness
