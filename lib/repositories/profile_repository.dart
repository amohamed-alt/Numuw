import 'package:supabase_flutter/supabase_flutter.dart';

import 'repo_utils.dart';

class ProfileRepository {
  ProfileRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<void> upsertCurrentProfile({required String fullName}) async {
    final name = blankToNull(fullName);
    if (name == null) return;
    await _client.from('profiles').upsert({
      'id': currentUserId(),
      'full_name': name,
      'locale': 'ar',
      'timezone': DateTime.now().timeZoneName,
    });
  }
}
