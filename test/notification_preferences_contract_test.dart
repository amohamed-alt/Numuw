import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('notification preferences stay opt-in at the push channel level', () {
    final migration = File(
      'supabase/migrations/20260830030500_add_notification_preferences.sql',
    ).readAsStringSync();
    final model = File(
      'lib/models/notification_preferences.dart',
    ).readAsStringSync();

    expect(migration, contains('push_enabled boolean not null default false'));
    expect(model, contains('pushEnabled: false'));
  });

  test('notification preferences are protected by own-user RLS', () {
    final migration = File(
      'supabase/migrations/20260830030500_add_notification_preferences.sql',
    ).readAsStringSync();

    expect(migration, contains('alter table public.notification_preferences enable row level security'));
    expect(migration, contains('using (user_id = (select auth.uid()))'));
    expect(migration, contains('with check (user_id = (select auth.uid()))'));
    expect(migration, contains('on delete cascade'));
  });

  test('repository refuses cross-user preference writes and validates quiet hours', () {
    final source = File(
      'lib/repositories/notification_preferences_repository.dart',
    ).readAsStringSync();

    expect(source, contains("preferences.userId != user.id"));
    expect(source, contains("throw StateError('Cannot update notification preferences for another user')"));
    expect(source, contains('_validateQuietHours(preferences)'));
    expect(source, contains(".upsert(preferences.toUpsertJson(), onConflict: 'user_id')"));
  });
}
