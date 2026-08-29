import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/numuw_app.dart';
import 'screens/design_preview/ui_review_app.dart';
import 'services/notification_service.dart';
import 'state/app_preferences.dart';
import 'state/log_timer_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const uiReviewMode = bool.fromEnvironment('NUMUW_UI_REVIEW');
  if (uiReviewMode) {
    runApp(const NumuwUiReviewApp());
    return;
  }

  const sentryDsn = String.fromEnvironment('SENTRY_DSN');
  const appEnv = String.fromEnvironment('APP_ENV', defaultValue: 'development');

  Future<void> runner() async {
    final startupError = await _initializeSupabase();

    runApp(NumuwApp(startupError: startupError));

    AppPreferences.instance.load();
    LogTimerState.instance.load();
    NotificationService.instance.initialize().catchError((Object error, StackTrace stackTrace) {
      debugPrint('Notification initialization failed: $error');
      if (sentryDsn.isNotEmpty) {
        Sentry.captureException(error, stackTrace: stackTrace);
      }
    });
  }

  if (sentryDsn.isEmpty) {
    await runner();
    return;
  }

  await SentryFlutter.init(
    (options) {
      options
        ..dsn = sentryDsn
        ..environment = appEnv
        ..tracesSampleRate = appEnv == 'production' ? 0.15 : 1.0
        ..sendDefaultPii = false
        ..attachScreenshot = false
        ..beforeSend = (event, hint) {
          // Numuw handles child/family health-adjacent data. Keep telemetry
          // intentionally minimal: no screenshots or default PII.
          return event;
        };
    },
    appRunner: runner,
  );
}

Future<String?> _initializeSupabase() async {
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  if (supabaseUrl.isEmpty || supabasePublishableKey.isEmpty) {
    return 'إعدادات Supabase غير مكتملة. شغّلي التطبيق باستخدام ملف config/dev.json.';
  }

  try {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabasePublishableKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
    return null;
  } catch (error, stackTrace) {
    debugPrint('Supabase initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);

    if (const String.fromEnvironment('SENTRY_DSN').isNotEmpty) {
      await Sentry.captureException(error, stackTrace: stackTrace);
    }

    return 'تعذر تهيئة الاتصال بالخادم. تحققي من إعدادات Supabase.';
  }
}
