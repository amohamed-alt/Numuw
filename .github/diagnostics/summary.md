# Latest Numuw redesign CI diagnostics

Generated from commit: ef92d20bfa3df02526a18af8e8a5c30bd2826479

## Analyze summary

## Test summary
00:00 +0: loading /home/runner/work/Numuw/Numuw/test/health_sources_test.dart
00:00 +0: /home/runner/work/Numuw/Numuw/test/health_sources_test.dart: Arab-country health source registry covers the configured Arab countries
00:00 +1: /home/runner/work/Numuw/Numuw/test/health_sources_test.dart: Arab-country health source registry every country has auditable vaccination source metadata
00:00 +2: /home/runner/work/Numuw/Numuw/test/health_sources_test.dart: Arab-country health source registry global sources remain available
00:00 +3: loading /home/runner/work/Numuw/Numuw/test/health_content_test.dart
00:00 +3: /home/runner/work/Numuw/Numuw/test/health_content_test.dart: official health source catalog contains required country vaccination sources and global references
00:00 +4: /home/runner/work/Numuw/Numuw/test/health_content_test.dart: vaccination schedule catalog supports Egypt, Saudi Arabia, and UAE without invented dose rows
00:00 +4 -1: /home/runner/work/Numuw/Numuw/test/health_content_test.dart: vaccination schedule catalog supports Egypt, Saudi Arabia, and UAE without invented dose rows [E]
00:00 +4 -1: /home/runner/work/Numuw/Numuw/test/health_content_test.dart: vaccination schedule catalog scheduled dose status and due date calculation are deterministic
00:00 +5 -1: /home/runner/work/Numuw/Numuw/test/health_content_test.dart: vaccination schedule catalog vaccination records drive completed and next dose calculations
00:00 +6 -1: /home/runner/work/Numuw/Numuw/test/health_content_test.dart: WHO growth standards keeps charts gated until official LMS rows are imported
00:00 +7 -1: /home/runner/work/Numuw/Numuw/test/health_content_test.dart: development and feeding library returns age-banded activity content
00:00 +8 -1: /home/runner/work/Numuw/Numuw/test/health_content_test.dart: development and feeding library calculates completed months correctly
00:00 +9 -1: /home/runner/work/Numuw/Numuw/test/health_content_test.dart: development and feeding library feeding library keeps source attribution
00:00 +10 -1: loading /home/runner/work/Numuw/Numuw/test/weekly_summary_test.dart
00:01 +10 -1: /home/runner/work/Numuw/Numuw/test/weekly_summary_test.dart: WeeklySummaryCalculator calculates current and previous week totals
00:01 +11 -1: /home/runner/work/Numuw/Numuw/test/weekly_summary_test.dart: WeeklySummaryCalculator does not count pumping as normal feeding
00:01 +12 -1: /home/runner/work/Numuw/Numuw/test/weekly_summary_test.dart: WeeklySummaryCalculator returns insufficient data when both periods are empty
00:01 +13 -1: /home/runner/work/Numuw/Numuw/test/weekly_summary_test.dart: WeeklySummaryCalculator previous zero never generates infinity wording
00:01 +14 -1: /home/runner/work/Numuw/Numuw/test/weekly_summary_test.dart: WeeklySummaryCalculator detects increase, decrease, and stable trend
00:01 +15 -1: /home/runner/work/Numuw/Numuw/test/weekly_summary_test.dart: WeeklySummaryCalculator ignores events outside the rolling 14 day window
00:01 +16 -1: loading /home/runner/work/Numuw/Numuw/test/ai_assistant_service_test.dart
00:08 +16 -1: /home/runner/work/Numuw/Numuw/test/ai_assistant_service_test.dart: missing session maps to invalid session
00:08 +17 -1: /home/runner/work/Numuw/Numuw/test/ai_assistant_service_test.dart: service maps timeout errors
00:08 +18 -1: /home/runner/work/Numuw/Numuw/test/ai_assistant_service_test.dart: service maps HTTP 401
00:08 +19 -1: /home/runner/work/Numuw/Numuw/test/ai_assistant_service_test.dart: service maps HTTP 403
00:08 +20 -1: /home/runner/work/Numuw/Numuw/test/ai_assistant_service_test.dart: service maps HTTP 429
00:08 +21 -1: /home/runner/work/Numuw/Numuw/test/ai_assistant_service_test.dart: service returns structured success response
00:08 +22 -1: /home/runner/work/Numuw/Numuw/test/ai_assistant_service_test.dart: service allows parse responses with message but no actions
00:08 +23 -1: /home/runner/work/Numuw/Numuw/test/ai_assistant_service_test.dart: malformed response maps to invalid ai response
00:08 +24 -1: loading /home/runner/work/Numuw/Numuw/test/numuw_ui_smoke_test.dart
00:09 +24 -1: /home/runner/work/Numuw/Numuw/test/numuw_ui_smoke_test.dart: welcome screen renders final onboarding controls
00:10 +25 -1: /home/runner/work/Numuw/Numuw/test/numuw_ui_smoke_test.dart: bottom navigation updates the selected tab
00:10 +26 -1: /home/runner/work/Numuw/Numuw/test/numuw_ui_smoke_test.dart: center action opens quick logging sheet
00:10 +27 -1: /home/runner/work/Numuw/Numuw/test/numuw_ui_smoke_test.dart: active feeding timer appears in final feeding screen
00:11 +28 -1: /home/runner/work/Numuw/Numuw/test/numuw_ui_smoke_test.dart: active sleep timer shows wake action
00:11 +29 -1: /home/runner/work/Numuw/Numuw/test/numuw_ui_smoke_test.dart: dirty diaper choice reveals color controls
00:11 +30 -1: /home/runner/work/Numuw/Numuw/test/numuw_ui_smoke_test.dart: light and dark theme smoke tests
00:11 +31 -1: /home/runner/work/Numuw/Numuw/test/numuw_ui_smoke_test.dart: small-screen onboarding does not overflow
00:11 +32 -1: loading /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart
00:12 +32 -1: /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart: parse daily summary response
00:12 +33 -1: /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart: parse doctor summary response
00:12 +34 -1: /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart: parse one care event
00:12 +35 -1: /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart: parse multiple care events
00:12 +36 -1: /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart: reject unsupported event type
00:12 +37 -1: /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart: handle missing optional fields
00:12 +38 -1: /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart: handle invalid JSON safely
00:12 +39 -1: /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart: feeding methods mapping
00:12 +40 -1: /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart: feeding follow-up fields survive parsing and save mapping
00:12 +41 -1: /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart: pumping left/right quantity calculation
00:12 +42 -1: /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart: diaper wet dirty mapping
00:12 +43 -1: /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart: ambiguous time remains reviewable
00:12 +44 -1: loading /home/runner/work/Numuw/Numuw/test/assistant_screen_test.dart
00:13 +44 -1: /home/runner/work/Numuw/Numuw/test/assistant_screen_test.dart: assistant screen renders redesigned empty state
00:14 +45 -1: /home/runner/work/Numuw/Numuw/test/assistant_screen_test.dart: assistant screen can start a fresh chat
00:14 +46 -1: /home/runner/work/Numuw/Numuw/test/assistant_screen_test.dart: assistant screen dark theme smoke test
00:14 +47 -1: loading /home/runner/work/Numuw/Numuw/test/vaccination_plan_summary_test.dart
00:15 +47 -1: /home/runner/work/Numuw/Numuw/test/vaccination_plan_summary_test.dart: vaccination summary handles unavailable country schedule safely
00:15 +48 -1: /home/runner/work/Numuw/Numuw/test/vaccination_plan_summary_test.dart: vaccination summary prioritizes overdue and completion state
00:15 +49 -1: loading /home/runner/work/Numuw/Numuw/test/offline_care_event_queue_test.dart
00:15 +49 -1: /home/runner/work/Numuw/Numuw/test/offline_care_event_queue_test.dart: OfflineCareEventQueue stores and restores pending care event insert payloads
00:16 +50 -1: /home/runner/work/Numuw/Numuw/test/offline_care_event_queue_test.dart: OfflineCareEventQueue replacePending clears storage when no pending payload remains
00:16 +51 -1: loading /home/runner/work/Numuw/Numuw/test/widget_test.dart
00:21 +51 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Arabic age formatter shows weeks and days
00:21 +52 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: ChildProfile mapping handles nullable fields
00:21 +53 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: ChildGuardian mapping accepts RPC display name and email
00:21 +54 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: CareEvent mapping handles feeding fields
00:21 +55 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: New pumping event parsing exposes pumped amount
00:21 +56 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Split pumping amounts calculate the stored total
00:21 +57 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Missing split pumping metadata does not crash
00:21 +58 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Pumping metadata parses int, double, and numeric string values
00:21 +59 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Legacy feeding pumping record remains compatible
00:21 +60 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Normal feeding events are not counted as pumping
00:21 +61 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Pumping comparison calculates current and previous seven-day totals
00:21 +62 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Pumping comparison detects percentage increase
00:21 +63 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Pumping comparison detects percentage decrease
00:21 +64 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Pumping comparison treats changes within five percent as stable
00:21 +65 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Previous total zero does not generate infinity
00:21 +66 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Both pumping periods empty return insufficient data
00:21 +67 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Invalid zero or negative pumping amounts are ignored
00:21 +68 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Events outside the fourteen-day pumping range are ignored
00:21 +69 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Local day aggregation sums multiple pumping sessions per day
00:21 +70 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Different children are never mixed in pumping analytics
00:21 +71 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Feeding reminder uses average interval and ignores pumping
00:21 +72 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Medicine reminder is scheduled from medicine event
00:21 +73 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Vaccination reminder is scheduled at nine on due date
00:21 +74 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Egypt official vaccination schedule has source and expected size
00:21 +75 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Egypt official vaccination due dates are calculated from birth date
00:21 +76 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: CareEvent mapping never emits null metadata
00:21 +77 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: CareEvent mapping keeps multiple feeding methods metadata
00:21 +78 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: readableError returns Arabic timeout message
00:21 +79 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Old feeding_method remains available without feeding_methods metadata
00:21 +80 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Dashboard sleep calculation sums multiple sessions today
00:21 +81 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Dashboard sleep calculation clips sessions crossing midnight
00:21 +82 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Dashboard sleep calculation counts active sleep until now
00:21 +83 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Dashboard sleep calculation ignores invalid negative duration
00:21 +84 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Dashboard sleep calculation handles UTC-to-local boundary safely
00:21 +85 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Task title validation rejects malformed titles
00:21 +86 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Selected-child state propagation notifies listeners
00:21 +87 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Failed sleep save can preserve local session until success finish
00:21 +88 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Pumping timer remains associated with its original child
00:21 +89 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Numuw app shows setup error without Supabase config immediately
00:22 +90 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: MainShell lazily creates unopened tabs
00:22 +91 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Basic RTL widget smoke test
00:22 +92 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Sign in validation shows email and password errors
00:22 +93 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Sign up validation shows name email and password errors
00:23 +94 -1: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Basic RTL pumping-screen widget test
00:23 +95 -1: Some tests failed.
