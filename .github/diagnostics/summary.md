# Latest Numuw redesign CI diagnostics

Generated from commit: c67aa3de3b981ab0f309f24fb40967c48d88e32b

## Analyze summary

## Test summary
00:00 +0: loading /home/runner/work/Numuw/Numuw/test/health_sources_test.dart
00:00 +0: /home/runner/work/Numuw/Numuw/test/health_sources_test.dart: Arab-country health source registry covers the configured Arab countries
00:00 +1: /home/runner/work/Numuw/Numuw/test/health_sources_test.dart: Arab-country health source registry every country has auditable vaccination source metadata
00:00 +2: /home/runner/work/Numuw/Numuw/test/health_sources_test.dart: Arab-country health source registry global sources remain available
00:00 +3: loading /home/runner/work/Numuw/Numuw/test/health_content_test.dart
00:00 +3: /home/runner/work/Numuw/Numuw/test/health_content_test.dart: official health source catalog contains required country vaccination sources and global references
00:00 +4: /home/runner/work/Numuw/Numuw/test/health_content_test.dart: vaccination schedule catalog supports Egypt, Saudi Arabia, and UAE without invented dose rows
00:00 +5: /home/runner/work/Numuw/Numuw/test/health_content_test.dart: vaccination schedule catalog scheduled dose status and due date calculation are deterministic
00:00 +6: /home/runner/work/Numuw/Numuw/test/health_content_test.dart: vaccination schedule catalog vaccination records drive completed and next dose calculations
00:00 +7: /home/runner/work/Numuw/Numuw/test/health_content_test.dart: WHO growth standards keeps charts gated until official LMS rows are imported
00:00 +8: /home/runner/work/Numuw/Numuw/test/health_content_test.dart: development and feeding library returns age-banded activity content
00:00 +9: /home/runner/work/Numuw/Numuw/test/health_content_test.dart: development and feeding library calculates completed months correctly
00:00 +10: /home/runner/work/Numuw/Numuw/test/health_content_test.dart: development and feeding library feeding library keeps source attribution
00:00 +11: loading /home/runner/work/Numuw/Numuw/test/weekly_summary_test.dart
00:01 +11: /home/runner/work/Numuw/Numuw/test/weekly_summary_test.dart: WeeklySummaryCalculator calculates current and previous week totals
00:01 +12: /home/runner/work/Numuw/Numuw/test/weekly_summary_test.dart: WeeklySummaryCalculator does not count pumping as normal feeding
00:01 +13: /home/runner/work/Numuw/Numuw/test/weekly_summary_test.dart: WeeklySummaryCalculator returns insufficient data when both periods are empty
00:01 +14: /home/runner/work/Numuw/Numuw/test/weekly_summary_test.dart: WeeklySummaryCalculator previous zero never generates infinity wording
00:01 +15: /home/runner/work/Numuw/Numuw/test/weekly_summary_test.dart: WeeklySummaryCalculator detects increase, decrease, and stable trend
00:01 +16: /home/runner/work/Numuw/Numuw/test/weekly_summary_test.dart: WeeklySummaryCalculator ignores events outside the rolling 14 day window
00:01 +17: loading /home/runner/work/Numuw/Numuw/test/ai_assistant_service_test.dart
00:07 +17: /home/runner/work/Numuw/Numuw/test/ai_assistant_service_test.dart: missing session maps to invalid session
00:07 +18: /home/runner/work/Numuw/Numuw/test/ai_assistant_service_test.dart: service maps timeout errors
00:07 +19: /home/runner/work/Numuw/Numuw/test/ai_assistant_service_test.dart: service maps HTTP 401
00:07 +20: /home/runner/work/Numuw/Numuw/test/ai_assistant_service_test.dart: service maps HTTP 403
00:07 +21: /home/runner/work/Numuw/Numuw/test/ai_assistant_service_test.dart: service maps HTTP 429
00:07 +22: /home/runner/work/Numuw/Numuw/test/ai_assistant_service_test.dart: service returns structured success response
00:07 +23: /home/runner/work/Numuw/Numuw/test/ai_assistant_service_test.dart: service allows parse responses with message but no actions
00:07 +24: /home/runner/work/Numuw/Numuw/test/ai_assistant_service_test.dart: malformed response maps to invalid ai response
00:07 +25: loading /home/runner/work/Numuw/Numuw/test/numuw_ui_smoke_test.dart
00:09 +25: /home/runner/work/Numuw/Numuw/test/numuw_ui_smoke_test.dart: welcome screen renders final onboarding controls
00:10 +26: /home/runner/work/Numuw/Numuw/test/numuw_ui_smoke_test.dart: bottom navigation updates the selected tab
00:10 +27: /home/runner/work/Numuw/Numuw/test/numuw_ui_smoke_test.dart: center action opens quick logging sheet
00:10 +28: /home/runner/work/Numuw/Numuw/test/numuw_ui_smoke_test.dart: active feeding timer appears in final feeding screen
00:10 +29: /home/runner/work/Numuw/Numuw/test/numuw_ui_smoke_test.dart: active sleep timer shows wake action
00:10 +30: /home/runner/work/Numuw/Numuw/test/numuw_ui_smoke_test.dart: dirty diaper choice reveals color controls
00:10 +31: /home/runner/work/Numuw/Numuw/test/numuw_ui_smoke_test.dart: light and dark theme smoke tests
00:10 +32: /home/runner/work/Numuw/Numuw/test/numuw_ui_smoke_test.dart: small-screen onboarding does not overflow
00:11 +33: loading /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart
00:11 +33: /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart: parse daily summary response
00:11 +34: /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart: parse doctor summary response
00:11 +35: /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart: parse one care event
00:11 +36: /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart: parse multiple care events
00:11 +37: /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart: reject unsupported event type
00:11 +38: /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart: handle missing optional fields
00:11 +39: /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart: handle invalid JSON safely
00:11 +40: /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart: feeding methods mapping
00:11 +41: /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart: feeding follow-up fields survive parsing and save mapping
00:11 +42: /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart: pumping left/right quantity calculation
00:11 +43: /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart: diaper wet dirty mapping
00:11 +44: /home/runner/work/Numuw/Numuw/test/ai_assistant_response_test.dart: ambiguous time remains reviewable
00:12 +45: loading /home/runner/work/Numuw/Numuw/test/assistant_screen_test.dart
00:12 +45: /home/runner/work/Numuw/Numuw/test/assistant_screen_test.dart: assistant screen renders redesigned empty state
00:13 +46: /home/runner/work/Numuw/Numuw/test/assistant_screen_test.dart: assistant screen can start a fresh chat
00:13 +47: /home/runner/work/Numuw/Numuw/test/assistant_screen_test.dart: assistant screen dark theme smoke test
00:13 +48: loading /home/runner/work/Numuw/Numuw/test/offline_care_event_queue_test.dart
00:14 +48: /home/runner/work/Numuw/Numuw/test/offline_care_event_queue_test.dart: OfflineCareEventQueue stores and restores pending care event insert payloads
00:14 +49: /home/runner/work/Numuw/Numuw/test/offline_care_event_queue_test.dart: OfflineCareEventQueue replacePending clears storage when no pending payload remains
00:14 +50: loading /home/runner/work/Numuw/Numuw/test/widget_test.dart
00:19 +50: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Arabic age formatter shows weeks and days
00:20 +51: /home/runner/work/Numuw/Numuw/test/widget_test.dart: ChildProfile mapping handles nullable fields
00:20 +52: /home/runner/work/Numuw/Numuw/test/widget_test.dart: ChildGuardian mapping accepts RPC display name and email
00:20 +53: /home/runner/work/Numuw/Numuw/test/widget_test.dart: CareEvent mapping handles feeding fields
00:20 +54: /home/runner/work/Numuw/Numuw/test/widget_test.dart: New pumping event parsing exposes pumped amount
00:20 +55: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Split pumping amounts calculate the stored total
00:20 +56: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Missing split pumping metadata does not crash
00:20 +57: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Pumping metadata parses int, double, and numeric string values
00:20 +58: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Legacy feeding pumping record remains compatible
00:20 +59: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Normal feeding events are not counted as pumping
00:20 +60: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Pumping comparison calculates current and previous seven-day totals
00:20 +61: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Pumping comparison detects percentage increase
00:20 +62: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Pumping comparison detects percentage decrease
00:20 +63: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Pumping comparison treats changes within five percent as stable
00:20 +64: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Previous total zero does not generate infinity
00:20 +65: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Both pumping periods empty return insufficient data
00:20 +66: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Invalid zero or negative pumping amounts are ignored
00:20 +67: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Events outside the fourteen-day pumping range are ignored
00:20 +68: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Local day aggregation sums multiple pumping sessions per day
00:20 +69: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Different children are never mixed in pumping analytics
00:20 +70: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Feeding reminder uses average interval and ignores pumping
00:20 +71: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Medicine reminder is scheduled from medicine event
00:20 +72: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Vaccination reminder is scheduled at nine on due date
00:20 +73: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Egypt official vaccination schedule has source and expected size
00:20 +74: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Egypt official vaccination due dates are calculated from birth date
00:20 +75: /home/runner/work/Numuw/Numuw/test/widget_test.dart: CareEvent mapping never emits null metadata
00:20 +76: /home/runner/work/Numuw/Numuw/test/widget_test.dart: CareEvent mapping keeps multiple feeding methods metadata
00:20 +77: /home/runner/work/Numuw/Numuw/test/widget_test.dart: readableError returns Arabic timeout message
00:20 +78: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Old feeding_method remains available without feeding_methods metadata
00:20 +79: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Dashboard sleep calculation sums multiple sessions today
00:20 +80: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Dashboard sleep calculation clips sessions crossing midnight
00:20 +81: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Dashboard sleep calculation counts active sleep until now
00:20 +82: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Dashboard sleep calculation ignores invalid negative duration
00:20 +83: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Dashboard sleep calculation handles UTC-to-local boundary safely
00:20 +84: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Task title validation rejects malformed titles
00:20 +85: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Selected-child state propagation notifies listeners
00:20 +86: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Failed sleep save can preserve local session until success finish
00:20 +87: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Pumping timer remains associated with its original child
00:20 +88: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Numuw app shows setup error without Supabase config immediately
00:20 +89: /home/runner/work/Numuw/Numuw/test/widget_test.dart: MainShell lazily creates unopened tabs
00:21 +90: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Basic RTL widget smoke test
00:21 +91: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Sign in validation shows email and password errors
00:21 +92: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Sign up validation shows name email and password errors
00:21 +93: /home/runner/work/Numuw/Numuw/test/widget_test.dart: Basic RTL pumping-screen widget test
00:22 +94: All tests passed!
