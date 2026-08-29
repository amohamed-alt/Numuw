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

    // A native push token belongs to one installation, not permanently to one
    // account. The authenticated Edge Function verifies the caller and then
    // atomically transfers token ownership with server-only credentials. This
    // avoids stale cross-account delivery without exposing a SECURITY DEFINER
    // database RPC through PostgREST.
    final response = await withRepositoryTimeout(
      _supabase.functions.invoke(
        'register-push-device',
        body: {
          'token': normalizedToken,
          'platform': normalizedPlatform,
          'timezone': _cleanOptional(timezone),
          'locale': _cleanOptional(locale),
          'appVersion': _cleanOptional(appVersion),
        },
      ),
    );
    if (response.status < 200 || response.status >= 300) {
      throw StateError('Push device registration failed');
    }
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
