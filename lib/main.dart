import 'dart:async';

import 'package:flutter/foundation.dart';
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

  // Nothing below this line is allowed to prevent the first Flutter frame.
  // These services are enhancements and are initialized after startup with
  // their failures isolated from the application bootstrap.
  unawaited(_initializeSecondaryServices());
}

Future<void> _initializeSecondaryServices() async {
  // Yield once so runApp can attach the Flutter view before plugins initialize.
  await Future<void>.delayed(Duration.zero);

  await _runStartupTask('AppPreferences', AppPreferences.instance.load);
  await _runStartupTask('LogTimerState', LogTimerState.instance.load);
  await _runStartupTask(
    'NetworkStatusService',
    NetworkStatusService.instance.initialize,
  );

  // Deep links and local notifications are native-app capabilities. They are
  // intentionally skipped on the GitHub Pages/web preview where they are not
  // required and may not have a supported platform implementation.
  if (!kIsWeb) {
    await _runStartupTask('DeepLinkService', DeepLinkService.instance.initialize);
    await _runStartupTask(
      'NotificationService',
      NotificationService.instance.initialize,
    );
  }
}

Future<void> _runStartupTask(
  String name,
  Future<void> Function() task,
) async {
  try {
    await task();
  } catch (error, stackTrace) {
    debugPrint('$name initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}
