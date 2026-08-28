import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/numuw_app.dart';
import 'services/deep_link_service.dart';
import 'services/network_status_service.dart';
import 'services/notification_service.dart';
import 'services/observability_service.dart';
import 'state/app_preferences.dart';
import 'state/log_timer_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (ObservabilityService.enabled) {
    await SentryFlutter.init(
      (options) {
        options.dsn = ObservabilityService.dsn;
        options.sendDefaultPii = false;
        options.tracesSampleRate = 0.05;
        options.environment = const String.fromEnvironment(
          'APP_ENV',
          defaultValue: 'production',
        );
      },
      appRunner: _bootstrap,
    );
  } else {
    await _bootstrap();
  }
}

Future<void> _bootstrap() async {
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  String? startupError;
  if (supabaseUrl.isEmpty || supabasePublishableKey.isEmpty) {
    startupError =
        'إعدادات Supabase غير مكتملة. شغّلي التطبيق باستخدام ملف config/dev.json.';
  } else {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: supabasePublishableKey,
      );
    } catch (error, stackTrace) {
      debugPrint('Supabase initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      startupError = 'تعذر تهيئة الاتصال بالخادم. تحققي من إعدادات Supabase.';
    }
  }

  runApp(NumuwApp(startupError: startupError));

  AppPreferences.instance.load();
  LogTimerState.instance.load();
  NetworkStatusService.instance.initialize();
  DeepLinkService.instance.initialize();
  NotificationService.instance.initialize().catchError((Object error) {
    debugPrint('Notification initialization failed: $error');
  });
}
