# Latest Numuw redesign CI diagnostics

Generated from commit: 1b7cd2980bab2f2fcee02008ae6442be03952657

## Analyze summary

## Test summary
00:00 +0: loading /home/runner/work/Numuw/Numuw/test/health_sources_test.dart
00:00 +0: /home/runner/work/Numuw/Numuw/test/health_sources_test.dart: Arab-country health source registry covers the configured Arab countries
00:00 +1: /home/runner/work/Numuw/Numuw/test/health_sources_test.dart: Arab-country health source registry every country has auditable vaccination source metadata
00:00 +2: /home/runner/work/Numuw/Numuw/test/health_sources_test.dart: Arab-country health source registry global sources remain available
00:00 +3: loading /home/runner/work/Numuw/Numuw/test/vaccination_plan_mapper_test.dart
00:00 +3: /home/runner/work/Numuw/Numuw/test/vaccination_plan_mapper_test.dart: mapper links completed Supabase rows with the selected schedule
00:00 +4: /home/runner/work/Numuw/Numuw/test/vaccination_plan_mapper_test.dart: mapper prefers official dose id when labels differ
00:00 +5: loading /home/runner/work/Numuw/Numuw/test/health_content_test.dart
00:01 +5: /home/runner/work/Numuw/Numuw/test/health_content_test.dart: official health source catalog contains required country vaccination sources and global references
00:01 +6: /home/runner/work/Numuw/Numuw/test/health_content_test.dart: vaccination schedule catalog keeps country schedules source-gated and avoids verified invented rows
00:01 +7: /home/runner/work/Numuw/Numuw/test/health_content_test.dart: vaccination schedule catalog scheduled dose status and due date calculation are deterministic
00:01 +8: /home/runner/work/Numuw/Numuw/test/health_content_test.dart: vaccination schedule catalog vaccination records drive completed and next dose calculations
00:01 +9: /home/runner/work/Numuw/Numuw/test/health_content_test.dart: WHO growth standards keeps chart display gated while seeded LMS rows are under review
00:01 +10: /home/runner/work/Numuw/Numuw/test/health_content_test.dart: development and feeding library returns age-banded activity content
00:01 +11: /home/runner/work/Numuw/Numuw/test/health_content_test.dart: development and feeding library calculates completed months correctly
00:01 +12: /home/runner/work/Numuw/Numuw/test/health_content_test.dart: development and feeding library feeding library keeps source attribution
00:01 +13: loading /home/runner/work/Numuw/Numuw/test/growth_chart_series_test.dart
00:02 +13: /home/runner/work/Numuw/Numuw/test/growth_chart_series_test.dart: WHO LMS seed rows are source gated
00:02 +14: /home/runner/work/Numuw/Numuw/test/growth_chart_series_test.dart: growth chart series calculates completed months and z score
00:02 +15: loading /home/runner/work/Numuw/Numuw/test/weekly_summary_test.dart
00:02 +15: /home/runner/work/Numuw/Numuw/test/weekly_summary_test.dart: WeeklySummaryCalculator calculates current and previous week totals
00:02 +16: /home/runner/work/Numuw/Numuw/test/weekly_summary_test.dart: WeeklySummaryCalculator does not count pumping as normal feeding
00:02 +17: /home/runner/work/Numuw/Numuw/test/weekly_summary_test.dart: WeeklySummaryCalculator returns insufficient data when both periods are empty
00:02 +18: /home/runner/work/Numuw/Numuw/test/weekly_summary_test.dart: WeeklySummaryCalculator previous zero never generates infinity wording
00:02 +19: /home/runner/work/Numuw/Numuw/test/weekly_summary_test.dart: WeeklySummaryCalculator detects increase, decrease, and stable trend
00:02 +20: /home/runner/work/Numuw/Numuw/test/weekly_summary_test.dart: WeeklySummaryCalculator ignores events outside the rolling 14 day window
00:02 +21: loading /home/runner/work/Numuw/Numuw/test/ai_assistant_service_test.dart
00:08 +21: /home/runner/work/Numuw/Numuw/test/ai_assistant_service_test.dart: missing session maps to invalid session
00:08 +22: /home/runner/work/Numuw/Numuw/test/ai_assistant_service_test.dart: service maps timeout errors
00:08 +23: /home/runner/work/Numuw/Numuw/test/ai_assistant_service_test.dart: service maps HTTP 401
00:08 +24: /home/runner/work/Numuw/Numuw/test/ai_assistant_service_test.dart: service maps HTTP 403
00:08 +25: /home/runner/work/Numuw/Numuw/test/ai_assistant_service_test.dart: service maps HTTP 429
00:08 +26: /home/runner/work/Numuw/Numuw/test/ai_assistant_service_test.dart: service returns structured success response
00:08 +27: /home/runner/work/Numuw/Numuw/test/ai_assistant_service_test.dart: service allows parse responses with message but no actions
00:08 +28: /home/runner/work/Numuw/Numuw/test/ai_assistant_service_test.dart: malformed response maps to invalid ai response
00:08 +29: loading /home/runner/work/Numuw/Numuw/test/numuw_ui_smoke_test.dart
00:10 +29: /home/runner/work/Numuw/Numuw/test/numuw_ui_smoke_test.dart: welcome screen renders final onboarding controls
00:11 +30: /home/runner/work/Numuw/Numuw/test/numuw_ui_smoke_test.dart: bottom navigation updates the selected tab
00:11 +31: /home/runner/work/Numuw/Numuw/test/numuw_ui_smoke_test.dart: center action opens quick logging sheet
00:11 +32: /home/runner/work/Numuw/Numuw/test/numuw_ui_smoke_test.dart: active feeding timer appears in final feeding screen
00:12 +33: /home/runner/work/Numuw/Numuw/test/numuw_ui_smoke_test.dart: active sleep timer shows wake action
00:12 +34: /home/runner/work/Numuw/Numuw/test/numuw_ui_smoke_test.dart: dirty diaper choice reveals color controls
00:12 +35: /home/runner/work/Numuw/Numuw/test/numuw_ui_smoke_test.dart: light and dark theme smoke tests
00:12 +36: /home/runner/work/Numuw/Numuw/test/numuw_ui_smoke_test.dart: small-screen onboarding does not overflow
00:12 +37: loading /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart
00:13 +37: /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart: parse daily summary response
00:13 +38: /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart: parse doctor summary response
00:13 +39: /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart: parse one care event
00:13 +40: /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart: parse multiple care events
00:13 +41: /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart: reject unsupported event type
00:13 +42: /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart: handle missing optional fields
00:13 +43: /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart: handle invalid JSON safely
00:13 +44: /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart: feeding methods mapping
00:13 +45: /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart: feeding follow-up fields survive parsing and save mapping
00:13 +46: /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart: pumping left/right quantity calculation
00:13 +47: /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart: diaper wet dirty mapping
00:13 +48: /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart: ambiguous time remains reviewable
00:13 +49: loading /home/runner/work/Numuw/Numuw/test/assistant_screen_test.dart
00:14 +49: /home/runner/work/Numuw/Numuw/test/assistant_screen_test.dart: assistant screen renders redesigned empty state
00:14 +50: /home/runner/work/Numuw/Numuw/test/assistant_screen_test.dart: assistant screen can start a fresh chat
00:15 +51: /home/runner/work/Numuw/Numuw/test/assistant_screen_test.dart: assistant screen dark theme smoke test
00:15 +52: loading /home/runner/work/Numuw/Numuw/test/growth_math_test.dart
00:15 +52: /home/runner/work/Numuw/Numuw/test/growth_math_test.dart: zScore returns zero when value equals m
00:15 +53: /home/runner/work/Numuw/Numuw/test/growth_math_test.dart: zScore supports l zero rows
00:15 +54: /home/runner/work/Numuw/Numuw/test/growth_math_test.dart: assess returns unavailable without a matching row
00:15 +55: /home/runner/work/Numuw/Numuw/test/growth_math_test.dart: assess picks matching row and categorizes bands
00:15 +56: loading /home/runner/work/Numuw/Numuw/test/vaccination_plan_summary_test.dart
00:16 +56: /home/runner/work/Numuw/Numuw/test/vaccination_plan_summary_test.dart: vaccination summary handles unavailable country schedule safely
00:16 +57: /home/runner/work/Numuw/Numuw/test/vaccination_plan_summary_test.dart: vaccination summary prioritizes overdue and completion state
00:16 +58: loading /home/runner/work/Numuw/Numuw/test/offline_care_event_queue_test.dart
00:17 +58: /home/runner/work/Numuw/Numuw/test/offline_care_event_queue_test.dart: OfflineCareEventQueue stores and restores pending care event insert payloads
00:17 +59: /home/runner/work/Numuw/Numuw/test/offline_care_event_queue_test.dart: OfflineCareEventQueue replacePending clears storage when no pending payload remains
00:17 +60: loading /home/runner/work/Numuw/Numuw/test/widget_test.dart
00:22 +60: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Arabic age formatter shows weeks and days
00:22 +61: /home/runner/work/Numuw/Numuw/test/widget_test.dart: ChildProfile mapping handles nullable fields
00:22 +62: /home/runner/work/Numuw/Numuw/test/widget_test.dart: ChildGuardian mapping accepts RPC display name and email
00:22 +63: /home/runner/work/Numuw/Numuw/test/widget_test.dart: CareEvent mapping handles feeding fields
00:22 +64: /home/runner/work/Numuw/Numuw/test/widget_test.dart: New pumping event parsing exposes pumped amount
00:22 +65: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Split pumping amounts calculate the stored total
00:22 +66: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Missing split pumping metadata does not crash
00:22 +67: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Pumping metadata parses int, double, and numeric string values
00:22 +68: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Legacy feeding pumping record remains compatible
00:22 +69: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Normal feeding events are not counted as pumping
00:22 +70: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Pumping comparison calculates current and previous seven-day totals
00:22 +71: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Pumping comparison detects percentage increase
00:22 +72: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Pumping comparison detects percentage decrease
00:22 +73: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Pumping comparison treats changes within five percent as stable
00:22 +74: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Previous total zero does not generate infinity
00:22 +75: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Both pumping periods empty return insufficient data
00:22 +76: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Invalid zero or negative pumping amounts are ignored
00:22 +77: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Events outside the fourteen-day pumping range are ignored
00:22 +78: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Local day aggregation sums multiple pumping sessions per day
00:22 +79: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Different children are never mixed in pumping analytics
00:22 +80: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Feeding reminder uses average interval and ignores pumping
00:22 +81: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Medicine reminder is scheduled from medicine event
00:22 +82: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Vaccination reminder is scheduled at nine on due date
00:22 +83: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Egypt official vaccination schedule has source and expected size
00:22 +84: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Egypt official vaccination due dates are calculated from birth date
00:22 +85: /home/runner/work/Numuw/Numuw/test/widget_test.dart: CareEvent mapping never emits null metadata
00:22 +86: /home/runner/work/Numuw/Numuw/test/widget_test.dart: CareEvent mapping keeps multiple feeding methods metadata
00:22 +87: /home/runner/work/Numuw/Numuw/test/widget_test.dart: readableError returns Arabic timeout message
00:22 +88: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Old feeding_method remains available without feeding_methods metadata
00:22 +89: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Dashboard sleep calculation sums multiple sessions today
00:22 +90: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Dashboard sleep calculation clips sessions crossing midnight
00:22 +91: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Dashboard sleep calculation counts active sleep until now
00:22 +92: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Dashboard sleep calculation ignores invalid negative duration
00:22 +93: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Dashboard sleep calculation handles UTC-to-local boundary safely
00:22 +94: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Task title validation rejects malformed titles
00:22 +95: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Selected-child state propagation notifies listeners
00:22 +96: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Failed sleep save can preserve local session until success finish
00:22 +97: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Pumping timer remains associated with its original child
00:22 +98: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Numuw app shows setup error without Supabase config immediately
00:23 +99: /home/runner/work/Numuw/Numuw/test/widget_test.dart: MainShell lazily creates unopened tabs
00:23 +100: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Basic RTL widget smoke test
00:23 +101: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Sign in validation shows email and password errors
00:24 +102: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Sign up validation shows name email and password errors
00:24 +103: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Basic RTL pumping-screen widget test
00:24 +104: All tests passed!
