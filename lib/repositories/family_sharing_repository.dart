// ignore_for_file: prefer_initializing_formals

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/child_guardian.dart';
import 'repo_utils.dart';

class FamilySharingRepository {
  FamilySharingRepository({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;
  SupabaseClient get _supabase => _client ?? Supabase.instance.client;

  static const inviteColumns =
      'id,child_id,invite_code,invited_email,role,status,expires_at,created_at';

  Future<List<ChildGuardian>> fetchGuardians(String childId) async {
    final rows = await withRepositoryTimeout(
      _supabase.rpc('get_child_guardians', params: {'p_child_id': childId}),
    );
    return (rows as List)
        .map(
          (row) => ChildGuardian.fromMap(Map<String, dynamic>.from(row as Map)),
        )
        .toList();
  }

  Future<FamilyInvite> createInvite({
    required String childId,
    String? invitedEmail,
  }) async {
    final row = await withRepositoryTimeout(
      _supabase
          .from('family_invites')
          .insert({
            'child_id': childId,
            'created_by': currentUserId(),
            'invited_email': blankToNull(invitedEmail)?.toLowerCase(),
            'role': 'guardian',
          })
          .select(inviteColumns)
          .single(),
    );
    return FamilyInvite.fromMap(Map<String, dynamic>.from(row));
  }

  Future<List<FamilyInvite>> fetchPendingInvites(String childId) async {
    final rows = await withRepositoryTimeout(
      _supabase
          .from('family_invites')
          .select(inviteColumns)
          .eq('child_id', childId)
          .eq('status', 'pending')
          .order('created_at', ascending: false),
    );
    return (rows as List)
        .map(
          (row) => FamilyInvite.fromMap(Map<String, dynamic>.from(row as Map)),
        )
        .toList();
  }

  Future<void> acceptInvite(String inviteCode) => withRepositoryTimeout(
    _supabase.rpc('accept_family_invite', params: {'invite_code': inviteCode}),
  );
}
