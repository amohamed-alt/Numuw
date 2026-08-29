# Numuw Product Build Map

This file is the source of truth for product scope, screen ownership, production readiness and the order in which AI agents should work.

## Status legend
- ✅ implemented in repository
- 🟡 implemented but needs production hardening/redesign
- 🔵 foundation added in this branch
- ⬜ planned/not yet complete

## Global app shell
| Area | Status | Notes |
|---|---|---|
| Splash/bootstrap | 🟡 | Existing screen; align with organic identity and startup error handling. |
| Authentication gate | 🟡 | Supabase-backed; add polished recovery states. |
| Sign in / sign up | 🟡 | Existing. Keep Arabic-first and add privacy/legal links before release. |
| Child onboarding | 🟡 | Existing. Extend pregnancy/newborn path and caregiver role choices. |
| Main bottom navigation | 🟡 | Existing. Replace generic icons with approved organic SVG vocabulary. |
| Design tokens | 🟡 | Existing token files; consolidate around Natural Organic palette. |
| Organic SVG system | 🔵 | Canonical icon vocabulary introduced in `lib/design`. |
| Motion system | 🔵 | Canonical motion timings/primitives introduced in `lib/design`. |
| Sentry bootstrap | 🔵 | Runtime-configured via `SENTRY_DSN`, no hard-coded secrets. |

## Core screens
| Screen / flow | Status | Production target |
|---|---|---|
| Today / يومك مع طفلك | 🟡 | Daily summary, last feeding/sleep/diaper, next vaccine, tip/activity, open tasks. |
| Quick Log / التسجيل | 🟡 | Feeding, sleep, diaper, food, medicine, temperature, note; one-handed entry. |
| Child / طفلي | 🟡 | Profile, growth, vaccines, milestones, reports, documents. |
| AI Assistant / اسألي المساعد | 🟡 | Safe general guidance + log summaries + doctor-question prep; never diagnosis. |
| More / المزيد | 🟡 | Family, settings, content, privacy, account/delete account. |
| Family sharing | 🟡 | Existing membership/task foundation. Add invite UX, roles, permissions matrix. |
| Pumping | 🟡 | Existing. Normalize with feeding analytics and organic UI. |
| Weekly share | 🟡 | Existing. Use safe summary language and organic share card. |

## Tracking modules
| Module | Status | Required data / behavior |
|---|---|---|
| Breastfeeding | 🟡 | Start/end timestamp, side, duration, burp/reflux notes. |
| Bottle/formula | 🟡 | Volume, milk type, timestamp, notes. |
| Sleep | 🟡 | Start/end timestamp, day/night summary, restored timers. |
| Diaper | 🟡 | Wet/dirty/both, optional color/consistency notes. |
| Food | ⬜ | Meals/foods tried/acceptance/notes; age-gated guidance. |
| Medicine/vitamins | 🟡 | User-entered prescribed instructions only; reminder/completion. |
| Temperature | 🟡 | Value/unit/method/timestamp, no diagnosis. |
| Growth | 🟡 | Weight, height, head circumference, date/source. |
| Vaccinations | 🟡 | Country schedule, next dose, completion, card/document attachment. |
| Notes | 🟡 | Free-form caregiver note, excluded from telemetry/error payloads. |

## Pregnancy / preparation
| Module | Status | Scope |
|---|---|---|
| Pregnancy home mode | ⬜ | Gestational context instead of child-day dashboard. |
| Hospital bag checklist | ⬜ | Customizable checklist. |
| Baby setup shopping | ⬜ | Necessary / can wait / unnecessary categories. |
| First week plan | ⬜ | Family task sharing and reminders. |
| Country paperwork | ⬜ | Source-backed, date-stamped informational content. |

## 6+ month nutrition
| Module | Status | Scope |
|---|---|---|
| Food log | ⬜ | Foods tried and reactions/notes without diagnosis. |
| Age-appropriate recipes | ⬜ | Reviewed content only. |
| Shopping list | ⬜ | Weekly household list. |
| Water guidance | ⬜ | Source-backed informational content only. |

## Mother wellbeing
| Module | Status | Scope |
|---|---|---|
| Water/rest | ⬜ | Gentle self-care reminders. |
| Mood journal | ⬜ | Private by default; no diagnosis. |
| Appointments/meds | ⬜ | Organizational only. |
| Help request | ⬜ | Assign a simple family task. |
| Safety resources | ⬜ | Country-appropriate escalation/resources; no mental-health diagnosis. |

## Doctor visit report
| Capability | Status | Notes |
|---|---|---|
| PDF generation | 🟡 | Existing report service. |
| Feeding/sleep summary | 🟡 | Validate time ranges and missing-data behavior. |
| Growth/vaccine summary | 🟡 | Add provenance and measurement dates. |
| Symptoms/notes | 🟡 | User-entered only; privacy-sensitive. |
| Doctor questions | 🟡 | Existing repository foundation. |
| Share/print | 🟡 | Existing PDF/printing dependencies. |

## Platform foundation
| Capability | Status | Notes |
|---|---|---|
| Supabase Auth | ✅ | Existing and active. |
| Postgres/RLS | 🟡 | Existing migrations; run current advisors after each change. |
| Family permissions | 🟡 | Existing tables/migrations; verify all RLS paths. |
| Offline write queue | 🟡 | Existing simple queue; evolve to durable idempotent retries. |
| Local notifications | 🟡 | Existing service; add deep links and dedupe. |
| Push notifications | ⬜ | Requires FCM/APNs project credentials and server registration. |
| Storage/documents | 🟡 | `child_documents` exists; verify bucket policies/UX. |
| AI Edge Function | 🟡 | Existing. Keep provider secret server-side and update safety/telemetry. |
| Sentry | 🔵 | Client wiring added; production requires DSN runtime secret/config. |
| Analytics | ⬜ | Choose privacy-conscious product analytics before launch. |
| Subscriptions | ⬜ | App Store / Play billing implementation and server receipt state. |
| Delete account/data | ⬜ | Must be complete before public store launch. |
| Backups/restore runbook | ⬜ | Configure and document production recovery. |

## Approved Natural Organic design system
Primary palette direction:
- Forest / deep eucalyptus: `#2F5D50`
- Sage: `#7FA68C`
- Mint: `#BFD9CB`
- Warm cream: `#FFF8EE`
- Sand: `#EEDFCB`
- Peach: `#F2B38E`
- Dusty blue: `#A9C8D8`
- Lavender: `#C9C0DF`
- Ink: `#263832`

Use colors semantically and maintain WCAG-readable foreground/background pairs. Decorative watercolor/organic illustrations can be richer, but functional controls must remain crisp.

## Release gates
A public release is not considered ready until all are true:
1. `flutter analyze` and `flutter test` pass.
2. Production iOS and Android builds pass with signing.
3. RLS/security advisor issues have no unresolved high-risk finding.
4. Account deletion and privacy policy flows work.
5. Medical informational content has source + review date.
6. AI refusal/escalation cases are tested.
7. Crash reporting uses a production Sentry DSN and excludes sensitive health/family content.
8. Push notification credentials and deep links are tested on physical devices.
9. App Store/Play disclosures, screenshots, privacy labels/data safety form are complete.
10. Backup/restore and incident response are documented.
