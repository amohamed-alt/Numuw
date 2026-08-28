import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class ObservabilityService {
  const ObservabilityService._();

  static const dsn = String.fromEnvironment('SENTRY_DSN');
  static bool get enabled => dsn.trim().isNotEmpty;

  static Future<void> capture(Object error, StackTrace stackTrace) async {
    if (!enabled || kDebugMode) return;
    await Sentry.captureException(error, stackTrace: stackTrace);
  }
}
