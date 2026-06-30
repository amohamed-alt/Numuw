import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/numuw_app.dart';
import 'state/app_preferences.dart';
import 'state/log_timer_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppPreferences.instance.load();
  await LogTimerState.instance.load();

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
}
