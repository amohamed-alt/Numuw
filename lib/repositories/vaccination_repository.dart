import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/vaccination.dart';
import 'repo_utils.dart';

class VaccinationRepository {
  VaccinationRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;
  final SupabaseClient _client;
  static const columns =
      'id,child_id,created_by,name,dose_label,scheduled_date,administered_date,provider,status,card_image_path,source_name,source_url,created_at,updated_at';

  Future<List<Vaccination>> fetch(String childId) async {
    final rows = await _client
        .from('vaccinations')
        .select(columns)
        .eq('child_id', childId)
        .order('scheduled_date');
    return (rows as List)
        .map(
          (row) => Vaccination.fromMap(Map<String, dynamic>.from(row as Map)),
        )
        .toList();
  }

  Future<Vaccination?> nextScheduled(String childId) async {
    final today = DateTime.now();
    final rows = await _client
        .from('vaccinations')
        .select(columns)
        .eq('child_id', childId)
        .eq('status', 'scheduled')
        .gte('scheduled_date', dateOnly(today)!)
        .order('scheduled_date')
        .limit(1);
    if ((rows as List).isEmpty) return null;
    return Vaccination.fromMap(Map<String, dynamic>.from(rows.first as Map));
  }

  Future<Vaccination> add({
    required String childId,
    required String name,
    String? doseLabel,
    DateTime? scheduledDate,
    DateTime? administeredDate,
    String? provider,
    String status = 'scheduled',
  }) async {
    final row = await _client
        .from('vaccinations')
        .insert({
          'child_id': childId,
          'created_by': currentUserId(),
          'name': name.trim(),
          'dose_label': blankToNull(doseLabel),
          'scheduled_date': dateOnly(scheduledDate),
          'administered_date': dateOnly(administeredDate),
          'provider': blankToNull(provider),
          'status': status,
        })
        .select(columns)
        .single();
    return Vaccination.fromMap(Map<String, dynamic>.from(row));
  }

  Future<void> updateStatus(String id, String status) async {
    await _client
        .from('vaccinations')
        .update({
          'status': status,
          'administered_date': status == 'completed'
              ? dateOnly(DateTime.now())
              : null,
        })
        .eq('id', id);
  }

  Future<void> delete(String id) async =>
      _client.from('vaccinations').delete().eq('id', id);

  Future<Vaccination> update({
    required String id,
    required String name,
    String? doseLabel,
    DateTime? scheduledDate,
    DateTime? administeredDate,
    String? provider,
    required String status,
  }) async {
    final row = await _client
        .from('vaccinations')
        .update({
          'name': name.trim(),
          'dose_label': blankToNull(doseLabel),
          'scheduled_date': dateOnly(scheduledDate),
          'administered_date': dateOnly(administeredDate),
          'provider': blankToNull(provider),
          'status': status,
        })
        .eq('id', id)
        .select(columns)
        .single();
    return Vaccination.fromMap(Map<String, dynamic>.from(row));
  }
}
