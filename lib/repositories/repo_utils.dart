import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/errors/app_error.dart';

String currentUserId() {
  final session = Supabase.instance.client.auth.currentSession;
  final userId = session?.user.id;
  if (session == null || userId == null) throw const MissingSessionException();
  return userId;
}

String? blankToNull(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}

String? dateOnly(DateTime? value) {
  if (value == null) return null;
  final local = value.toLocal();
  return '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}
