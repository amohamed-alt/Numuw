// ignore_for_file: prefer_initializing_formals

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/child_profile.dart';
import 'repo_utils.dart';
import 'vaccination_repository.dart';

class ChildRepository {
  ChildRepository({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;
  SupabaseClient get _supabase => _client ?? Supabase.instance.client;

  static const columns =
      'id,created_by,name,stage,birth_date,due_date,gender,feeding_type,blood_type,birth_weight_kg,photo_path,created_at,updated_at';

  Future<List<ChildProfile>> fetchCurrentUserChildren() async {
    final rows = await _supabase
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
    final row = await _supabase
        .from('children')
        .insert(payload)
        .select(columns)
        .single();
    final child = ChildProfile.fromMap(Map<String, dynamic>.from(row));
    if (child.stage == 'born' && child.birthDate != null) {
      await VaccinationRepository(client: _client).seedEgyptOfficialSchedule(
        childId: child.id,
        birthDate: child.birthDate!,
      );
    }
    return child;
  }

  Future<ChildProfile> updateChild(ChildProfile child) async {
    final currentRow = await _supabase
        .from('children')
        .select(columns)
        .eq('id', child.id)
        .single();
    final previous = ChildProfile.fromMap(
      Map<String, dynamic>.from(currentRow),
    );
    final row = await _supabase
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
    final updated = ChildProfile.fromMap(Map<String, dynamic>.from(row));
    if (previous.stage != 'born' &&
        updated.stage == 'born' &&
        updated.birthDate != null) {
      await VaccinationRepository(client: _client).seedEgyptOfficialSchedule(
        childId: updated.id,
        birthDate: updated.birthDate!,
      );
    }
    return updated;
  }
}
