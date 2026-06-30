import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/growth_measurement.dart';
import 'repo_utils.dart';

class GrowthRepository {
  GrowthRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;
  final SupabaseClient _client;
  static const columns =
      'id,child_id,created_by,measured_at,weight_kg,height_cm,head_circumference_cm,source,notes,created_at';

  Future<List<GrowthMeasurement>> fetch(String childId) async {
    final rows = await _client
        .from('growth_measurements')
        .select(columns)
        .eq('child_id', childId)
        .order('measured_at');
    return (rows as List)
        .map(
          (row) =>
              GrowthMeasurement.fromMap(Map<String, dynamic>.from(row as Map)),
        )
        .toList();
  }

  Future<GrowthMeasurement> add({
    required String childId,
    required DateTime measuredAt,
    double? weightKg,
    double? heightCm,
    double? headCm,
    String? source,
    String? notes,
  }) async {
    final row = await _client
        .from('growth_measurements')
        .insert({
          'child_id': childId,
          'created_by': currentUserId(),
          'measured_at': measuredAt.toUtc().toIso8601String(),
          'weight_kg': weightKg,
          'height_cm': heightCm,
          'head_circumference_cm': headCm,
          'source': blankToNull(source),
          'notes': blankToNull(notes),
        })
        .select(columns)
        .single();
    return GrowthMeasurement.fromMap(Map<String, dynamic>.from(row));
  }

  Future<void> delete(String id) async =>
      _client.from('growth_measurements').delete().eq('id', id);

  Future<GrowthMeasurement> update({
    required String id,
    required DateTime measuredAt,
    double? weightKg,
    double? heightCm,
    double? headCm,
    String? source,
    String? notes,
  }) async {
    final row = await _client
        .from('growth_measurements')
        .update({
          'measured_at': measuredAt.toUtc().toIso8601String(),
          'weight_kg': weightKg,
          'height_cm': heightCm,
          'head_circumference_cm': headCm,
          'source': blankToNull(source),
          'notes': blankToNull(notes),
        })
        .eq('id', id)
        .select(columns)
        .single();
    return GrowthMeasurement.fromMap(Map<String, dynamic>.from(row));
  }
}
