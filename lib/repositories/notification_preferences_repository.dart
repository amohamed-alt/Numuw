import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/notification_preferences.dart';
import 'repo_utils.dart';

class NotificationPreferencesRepository {
  NotificationPreferencesRepository({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  SupabaseClient get _supabase => _client ?? Supabase.instance.client;

  Future<NotificationPreferences> getOrCreate({
    String? timezone,
    String? locale,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw StateError('Authentication required');
    }

    final existing = await withRepositoryTimeout(
      _supabase
          .from('notification_preferences')
          .select()
          .eq('user_id', user.id)
          .maybeSingle(),
    );

    if (existing != null) {
      return NotificationPreferences.fromJson(existing);
    }

    final defaults = NotificationPreferences.defaults(user.id).copyWith(
      timezone: _cleanOptional(timezone),
      locale: _cleanOptional(locale),
    );

    final created = await withRepositoryTimeout(
      _supabase
          .from('notification_preferences')
          .insert(defaults.toUpsertJson())
          .select()
          .single(),
    );
    return NotificationPreferences.fromJson(created);
  }

  Future<NotificationPreferences> save(
    NotificationPreferences preferences,
  ) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw StateError('Authentication required');
    }
    if (preferences.userId != user.id) {
      throw StateError('Cannot update notification preferences for another user');
    }
    _validateQuietHours(preferences);

    final saved = await withRepositoryTimeout(
      _supabase
          .from('notification_preferences')
          .upsert(preferences.toUpsertJson(), onConflict: 'user_id')
          .select()
          .single(),
    );
    return NotificationPreferences.fromJson(saved);
  }

  Future<void> setPushEnabled(bool enabled) async {
    final current = await getOrCreate();
    await save(current.copyWith(pushEnabled: enabled));
  }

  static void _validateQuietHours(NotificationPreferences preferences) {
    final start = _cleanOptional(preferences.quietHoursStart);
    final end = _cleanOptional(preferences.quietHoursEnd);
    if ((start == null) != (end == null)) {
      throw const FormatException(
        'Quiet hours require both a start and an end time',
      );
    }
  }

  static String? _cleanOptional(String? value) {
    final cleaned = value?.trim();
    return cleaned == null || cleaned.isEmpty ? null : cleaned;
  }
}
