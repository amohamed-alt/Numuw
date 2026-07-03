// ignore_for_file: prefer_initializing_formals

import 'package:supabase_flutter/supabase_flutter.dart';

import 'repo_utils.dart';

class ProfileRepository {
  ProfileRepository({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;
  SupabaseClient get _supabase => _client ?? Supabase.instance.client;

  Future<void> upsertCurrentProfile({required String fullName}) async {
    final name = blankToNull(fullName);
    if (name == null) return;
    await _supabase.from('profiles').upsert({
      'id': currentUserId(),
      'full_name': name,
      'locale': 'ar',
      'timezone': DateTime.now().timeZoneName,
    });
  }
}
