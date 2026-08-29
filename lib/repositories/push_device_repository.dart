import 'package:supabase_flutter/supabase_flutter.dart';

import 'repo_utils.dart';

class PushDeviceRepository {
  PushDeviceRepository({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  SupabaseClient get _supabase => _client ?? Supabase.instance.client;

  Future<void> register({
    required String token,
    required String platform,
    String? timezone,
    String? locale,
    String? appVersion,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw StateError('Authentication required');
    }

    final normalizedToken = token.trim();
    if (normalizedToken.length < 20 || normalizedToken.length > 4096) {
      throw const FormatException('Invalid push token');
    }

    final normalizedPlatform = platform.trim().toLowerCase();
    if (!const {'android', 'ios', 'web'}.contains(normalizedPlatform)) {
      throw const FormatException('Unsupported push platform');
    }

    await withRepositoryTimeout(
      _supabase.from('push_devices').upsert(
        {
          'user_id': user.id,
          'platform': normalizedPlatform,
          'token': normalizedToken,
          'timezone': _cleanOptional(timezone),
          'locale': _cleanOptional(locale),
          'app_version': _cleanOptional(appVersion),
          'enabled': true,
          'last_seen_at': DateTime.now().toUtc().toIso8601String(),
        },
        onConflict: 'user_id,token',
      ),
    );
  }

  Future<void> refresh({
    required String token,
    String? timezone,
    String? locale,
    String? appVersion,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final normalizedToken = token.trim();
    if (normalizedToken.isEmpty) return;

    await withRepositoryTimeout(
      _supabase
          .from('push_devices')
          .update({
            'timezone': _cleanOptional(timezone),
            'locale': _cleanOptional(locale),
            'app_version': _cleanOptional(appVersion),
            'enabled': true,
            'last_seen_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('user_id', user.id)
          .eq('token', normalizedToken),
    );
  }

  Future<void> disable(String token) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final normalizedToken = token.trim();
    if (normalizedToken.isEmpty) return;

    await withRepositoryTimeout(
      _supabase
          .from('push_devices')
          .update({
            'enabled': false,
            'last_seen_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('user_id', user.id)
          .eq('token', normalizedToken),
    );
  }

  Future<void> remove(String token) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final normalizedToken = token.trim();
    if (normalizedToken.isEmpty) return;

    await withRepositoryTimeout(
      _supabase
          .from('push_devices')
          .delete()
          .eq('user_id', user.id)
          .eq('token', normalizedToken),
    );
  }

  Future<void> disableAllForCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await withRepositoryTimeout(
      _supabase
          .from('push_devices')
          .update({
            'enabled': false,
            'last_seen_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('user_id', user.id),
    );
  }

  static String? _cleanOptional(String? value) {
    final cleaned = value?.trim();
    return cleaned == null || cleaned.isEmpty ? null : cleaned;
  }
}
