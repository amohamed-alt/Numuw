# Numuw Claude Design Parity

Authoritative reference inspected: `design_reference/Numuw.dc.html`, `design_reference/support.js`, `design_reference/ios-frame.jsx`, `design_reference/.thumbnail`.

No `design_reference/screenshots/` or `design_reference/uploads/` directories are present in this checkout.

| Claude screen | Flutter screen | Current implementation status | Data source | Interaction behavior | Visual verification status | Remaining differences |
| --- | --- | --- | --- | --- | --- | --- |
| Splash | `SplashScreen` | Implemented native Flutter mark, title, subtitle, loading dots | Supabase init/session gate | Cold-start gate before auth routing | Verified by code against HTML dimensions | Native status bar, no fake iPhone frame in production |
| Welcome | `WelcomeScreen` | Implemented hero illustration area, primary/secondary buttons, feature rows | Local welcome flag | Buttons route to real sign-in/sign-up and persist welcome flag | Verified by source mapping | Emoji illustration approximates inline SVG |
| Sign in | `SignInScreen` | Implemented Claude header, back button, fields, forgot password, divider, create-account action | Supabase Auth | Real sign-in/reset password | Verified structurally | Native text fields instead of HTML inputs |
| Sign up | `SignUpScreen` | Implemented name/email/password form | Supabase Auth + profiles upsert when session exists | Real sign-up, email-confirmation handoff | Verified structurally | Profile upsert depends on existing RLS |
| Email confirmation | `EmailConfirmationScreen` | Implemented centered icon/title/copy/action | Supabase session confirmation state | Return to sign-in/sign-out | Verified structurally | Resend is informational until backend policy is confirmed |
| Onboarding 1 | `ChildOnboardingScreen` step 1 | Implemented selection cards | Local form state | Select born/pregnancy | Verified structurally | Uses native emoji instead of inline SVG |
| Onboarding 2 | `ChildOnboardingScreen` step 2 | Implemented name/date/gender/feeding | Local form state | Validates before next | Verified structurally | Date text input retained for web/mobile compatibility |
| Onboarding 3 | `ChildOnboardingScreen` step 3 | Implemented optional photo placeholder, blood grid, weight, save/skip | `children` table | Real child insert via repository | Verified structurally | Photo upload not implemented yet |
| Home | `HomeScreen` | Implemented hero, summary cards, pending tasks, recent activity | Dashboard repository | Pull/refresh and event notifier reload | Partially verified | Daily insight/activity cards still simplified |
| Quick log | `QuickLogScreen` main | Implemented seven colored buttons and real activity list | `care_events` | Opens internal real sub-screens | Verified structurally | Four-column wraps responsively on narrow widths |
| Feeding | `QuickLogScreen` feeding mode | Implemented timer/status/side/method/amount/toggles/notes | `care_events` | Real persisted active timer and save | Verified structurally | Timer survives app pause via persisted start time |
| Sleep | `QuickLogScreen` sleep mode | Implemented timer/start time/notes | `care_events` | Real persisted active timer and save | Verified structurally | Native timer text instead of HTML font stack |
| Diaper | `QuickLogScreen` diaper mode | Implemented three selection cards and save | `care_events` | Real diaper insert | Verified structurally | Notes stored in notes and metadata details |
| Food | `QuickLogScreen` food mode | Implemented food/quantity/reaction notes | `care_events.metadata` | Real food insert | Verified structurally | No separate reaction picker in current schema |
| Medicine | `QuickLogScreen` medicine mode | Implemented name/dose/safety warning | `care_events` | Real medicine insert | Verified structurally | No dosage advice by design |
| Temperature | `QuickLogScreen` temperature mode | Implemented input/warning/save | `care_events` | Validated real temperature insert | Verified structurally | Large display simplified to input-first layout |
| Note | `QuickLogScreen` note mode | Implemented large text area/save | `care_events` | Real note insert | Verified structurally | Neutral dark button maps through primary color |
| Profile | `ChildScreen` | Uses selected child, growth, vaccinations, tasks, questions | Repositories | Real add/status/toggle flows | Partially verified | Chart tabs/edit dialogs need more pixel tuning |
| Growth | `ChildScreen` growth section | Real list and add, delete repository available | `growth_measurements` | Add and fetch real data | Partially verified | Chart rendering simplified |
| Vaccinations | `ChildScreen` vaccination section | Real list/add/status, delete repository available | `vaccinations` | Add/complete/skip real data | Partially verified | Two-card last/next summary simplified |
| Family tasks | `ChildScreen` tasks | Real add/complete/reopen/delete repository exists | `family_tasks` | Toggle completion | Partially verified | Edit dialog simplified |
| Doctor questions | `ChildScreen` questions | Real add/answer/reopen/delete repository exists | `doctor_questions` | Toggle answered | Partially verified | Blue pending card simplified |
| Assistant | `AssistantScreen` | Implemented disclaimer, suggestions, bubbles, loading, input | Local service + Supabase data/questions | Local summary and save question | Verified structurally | No external AI until secure backend exists |
| More | `MoreScreen` | Implemented grouped rows, night toggle, account, child, report, privacy, sign-out | Supabase auth/session + local prefs | All rows perform action or open safe info | Verified structurally | Some feature rows are safe local placeholders |
| Night home/feed/sleep | Root theme + screens | Implemented persistent low-glare night palette | SharedPreferences | Toggle updates app theme | Partially verified | Claude-specific night sub-screen artwork simplified |
| Bottom nav | `AppBottomNavigation` | Five items, RTL order, 82px height, active mint | MainShell state | Preserves selected tab | Verified structurally | Uses Material icons matching intent |
| Loading states | Reusable components | Implemented visible Arabic loading/skeleton/dots | Repositories/auth | No blank white screen | Verified structurally | Skeleton shimmer simplified |
| Error states | Reusable components | Implemented readable Arabic cards | Error mapping | Retry where available | Verified structurally | Technical details logged only |
| Design preview | `DesignPreviewGallery` | Implemented debug-only gallery | Demo data only in preview | Enabled by Dart define | Verified by code | Not production route |
