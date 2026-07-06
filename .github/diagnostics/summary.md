# Latest Numuw redesign CI diagnostics

Generated from commit: bf52bfd630cd59a1d2304719256fd181d0d4362b

## Analyze summary
2 issues found. (ran in 20.2s)

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
00:01 +13: /home/runner/work/Numuw/Numuw/test/growth_chart_series_test.dart: WHO LMS seed rows are source gated
00:01 +14: /home/runner/work/Numuw/Numuw/test/growth_chart_series_test.dart: growth chart series calculates completed months and z score
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
00:13 +49: /home/runner/work/Numuw/Numuw/test/assistant_screen_test.dart: assistant screen renders redesigned empty state
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
00:21 +60 -1: loading /home/runner/work/Numuw/Numuw/test/widget_test.dart [E]
00:21 +60 -1: Some tests failed.
