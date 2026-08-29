# Numuw implementation master checklist

This document converts the product brief into an implementation/audit checklist. Statuses must describe reality; visual completion never implies backend completion.

## A. Core experience
- [x] Five-tab shell: Today / Quick Log / Child / Assistant / More.
- [x] Production Home uses the shared classy reference composition with Morning/Evening and custom SVG family.
- [ ] Quick Log landing: migrate final production presentation from Emoji/legacy icons to Numuw SVG components.
- [ ] Complete visual/state migration of every secondary route opened from the shell.

## B. Daily tracking
- [~] Feeding: real timer/save model exists; classy reference pane and side SVG illustrations exist; production wiring/final migration remains.
- [~] Pumping: production logic exists; final classy visual migration remains.
- [~] Sleep: production timer/logging exists; final classy visual migration and weekly insights remain.
- [~] Diaper: production logging exists; final custom-SVG UI and optional color/consistency fields need completion.
- [~] Food: basic event logging exists; age-aware 6+ month experience, tried/accepted/rejected foods, meal ideas and reviewed content remain.
- [~] Medicine: basic prescribed medicine logging/reminders exist; schedule/start/end/photo-of-prescription experience remains. No autonomous dosing.
- [~] Temperature and notes: logging exists; final classy visual migration remains.
- [ ] Arabic voice quick-log → structured event extraction with review-before-save.

## C. Child health and development
- [~] Growth repository/chart exists; migrate final UX and expose weight/height/head circumference cleanly.
- [~] Vaccinations repository/schedule/reminders exist; add country-aware official source metadata, last-reviewed date, card-photo storage, location and family sharing polish.
- [ ] Milestones/development weekly content and age-appropriate activities with non-diagnostic wording.
- [~] Doctor questions exist inside Child data model.
- [x] Doctor PDF generation/share service exists.
- [ ] Upgrade doctor report UX to include selected symptoms/notes/questions and polished preview before export.

## D. AI assistant
- [~] Assistant screen exists.
- [ ] Ground answers in logged child data where permitted, add structured follow-up questions and explicit source/red-flag UI.
- [ ] Voice input and streaming answer presentation.
- [ ] Emergency/doctor CTA states.
- [ ] Enforce: no diagnosis, no prescribing, no dose changes, no 'your child is safe', no emergency delay.

## E. Pregnancy and preparation
- [~] Onboarding supports pregnancy/born stages and due/birth dates.
- [ ] Pregnancy dashboard mode.
- [ ] Hospital bag checklist.
- [ ] Nursery/preparation checklist and essential-vs-delay shopping list.
- [ ] First-week plan, documents by country, doctor questions, parent task split and preparation budget.
- [ ] Affiliate-ready shopping links only after disclosure/quality rules are defined.

## F. Mother wellness
- [ ] Water tracking.
- [ ] Rest/sleep/self-care reminders.
- [ ] Prescribed mother medicine/supplement organizer.
- [ ] Appointments, small task list and request-help-from-family action.
- [ ] Mood log and breathing/relaxation experiences.
- [ ] Safety escalation/resources by country for strong distress indicators; no diagnosis.

## G. Family and caregivers
- [x] Family sharing screen/repository exists.
- [~] Family tasks exist.
- [ ] Finish roles/permissions UI for father/grandmother/nanny/other caregiver.
- [ ] Granular permissions: view log, add event, notifications, tasks, appointments, hide mother's private notes.
- [ ] Father/caregiver 'What can I do today?' dashboard.

## H. Content
- [ ] Stage-aware content feed: pregnancy/birth, feeding, sleep, daily care, vaccines, growth, nutrition, safety, home prep, father role, maternal postpartum health.
- [ ] One-minute summary, medical-review date, trustworthy sources and audio mode.
- [ ] Content search/bookmark/offline cache where useful.

## I. Commercial/product tiers
- [ ] Entitlement model for Free vs Premium.
- [ ] Free: one child, core logs, 7-day summary, base vaccines, weekly content, limited AI.
- [ ] Premium: no ads, full analytics, doctor PDFs, Arabic voice log, expanded AI policy limits, family sharing, multi-child, document/photo storage, monthly reports, routines and full audio content.
- [ ] Subscription/paywall implementation only after store product IDs and policy copy are approved.

## J. Community (post-MVP)
- [ ] Anonymous/general questions and age groups only after moderation tooling is ready.
- [ ] Block unsafe medical advice, bullying, misleading marketing, prescription sharing and unsafe child-photo exposure.

## K. Cross-cutting production quality
- [x] Shared custom SVG runtime via `flutter_svg`.
- [x] Automated test checks every registered Numuw SVG is bundled and non-empty.
- [x] Morning/Evening theme baseline.
- [~] Migrate remaining Material/Emoji production visuals to Numuw assets screen-by-screen.
- [ ] Repository-wide Arabic encoding/mojibake scan and repair (ChildScreen has confirmed corrupted literals requiring cleanup).
- [ ] Accessibility semantics and 44px minimum targets audit on every migrated screen.
- [ ] Reduced-motion audit on every animated screen.
- [ ] Offline/retry behavior audit for user-entered logs.
- [ ] Final release checklist: analyzer, tests, Android, iOS, permissions, privacy copy, crash reporting, performance profiling and store metadata.

Legend: `[x]` verified present, `[~]` partially present/logic exists but production UX is incomplete, `[ ]` not yet complete.
