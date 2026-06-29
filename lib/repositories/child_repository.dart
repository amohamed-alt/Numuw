import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/child_profile.dart';
import 'repo_utils.dart';

class ChildRepository {
  ChildRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const columns =
      'id,created_by,name,stage,birth_date,due_date,gender,feeding_type,blood_type,birth_weight_kg,photo_path,created_at,updated_at';

  Future<List<ChildProfile>> fetchCurrentUserChildren() async {
    final rows = await _client
        .from('children')
        .select(columns)
        .order('created_at');
    return (rows as List)
        .map(
          (row) => ChildProfile.fromMap(Map<String, dynamic>.from(row as Map)),
        )
        .toList();
  }

  Future<ChildProfile> createChild({
    required String name,
    required String stage,
    DateTime? birthDate,
    DateTime? dueDate,
    required String gender,
    required String feedingType,
    String? bloodType,
    double? birthWeightKg,
  }) async {
    final userId = currentUserId();
    final payload = {
      'created_by': userId,
      'name': name.trim(),
      'stage': stage,
      'birth_date': stage == 'born' ? dateOnly(birthDate) : null,
      'due_date': stage == 'pregnancy' ? dateOnly(dueDate) : null,
      'gender': gender,
      'feeding_type': feedingType,
      'blood_type': blankToNull(bloodType),
      'birth_weight_kg': birthWeightKg,
    };
    final row = await _client
        .from('children')
        .insert(payload)
        .select(columns)
        .single();
    return ChildProfile.fromMap(Map<String, dynamic>.from(row));
  }

  Future<ChildProfile> updateChild(ChildProfile child) async {
    final row = await _client
        .from('children')
        .update({
          'name': child.name.trim(),
          'stage': child.stage,
          'birth_date': child.stage == 'born'
              ? dateOnly(child.birthDate)
              : null,
          'due_date': child.stage == 'pregnancy'
              ? dateOnly(child.dueDate)
              : null,
          'gender': child.gender,
          'feeding_type': child.feedingType,
          'blood_type': blankToNull(child.bloodType),
          'birth_weight_kg': child.birthWeightKg,
        })
        .eq('id', child.id)
        .select(columns)
        .single();
    return ChildProfile.fromMap(Map<String, dynamic>.from(row));
  }
}
