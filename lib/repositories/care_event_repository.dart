import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/care_event.dart';
import 'repo_utils.dart';

class CareEventRepository {
  CareEventRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  static const columns =
      'id,child_id,created_by,event_type,started_at,ended_at,side,feeding_method,amount_ml,diaper_wet,diaper_dirty,temperature_c,medicine_name,medicine_dose,burped,vomited,notes,metadata,created_at,updated_at';

  Future<List<CareEvent>> fetchRecent(String childId, {int limit = 30}) async {
    final rows = await _client
        .from('care_events')
        .select(columns)
        .eq('child_id', childId)
        .order('started_at', ascending: false)
        .limit(limit);
    return (rows as List)
        .map((row) => CareEvent.fromMap(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  Future<List<CareEvent>> fetchBetween(
    String childId,
    DateTime start,
    DateTime end,
  ) async {
    final rows = await _client
        .from('care_events')
        .select(columns)
        .eq('child_id', childId)
        .gte('started_at', start.toUtc().toIso8601String())
        .lt('started_at', end.toUtc().toIso8601String())
        .order('started_at', ascending: false);
    return (rows as List)
        .map((row) => CareEvent.fromMap(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  Future<List<CareEvent>> fetchSleepOverlappingDay(
    String childId,
    DateTime start,
    DateTime end,
  ) async {
    final startIso = start.toUtc().toIso8601String();
    final endIso = end.toUtc().toIso8601String();
    final rows = await _client
        .from('care_events')
        .select(columns)
        .eq('child_id', childId)
        .eq('event_type', 'sleep')
        .lt('started_at', endIso)
        .or('ended_at.is.null,ended_at.gte.$startIso')
        .order('started_at', ascending: false);
    return (rows as List)
        .map((row) => CareEvent.fromMap(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  Future<CareEvent?> latestByType(String childId, String eventType) async {
    final rows = await _client
        .from('care_events')
        .select(columns)
        .eq('child_id', childId)
        .eq('event_type', eventType)
        .order('started_at', ascending: false)
        .limit(1);
    if ((rows as List).isEmpty) return null;
    return CareEvent.fromMap(Map<String, dynamic>.from(rows.first as Map));
  }

  Future<CareEvent> insert({
    required String childId,
    required String eventType,
    required DateTime startedAt,
    DateTime? endedAt,
    String? side,
    String? feedingMethod,
    double? amountMl,
    bool? diaperWet,
    bool? diaperDirty,
    double? temperatureC,
    String? medicineName,
    String? medicineDose,
    bool? burped,
    bool? vomited,
    String? notes,
    Map<String, dynamic>? metadata,
  }) async {
    final row = await _client
        .from('care_events')
        .insert({
          'child_id': childId,
          'created_by': currentUserId(),
          'event_type': eventType,
          'started_at': startedAt.toUtc().toIso8601String(),
          'ended_at': endedAt?.toUtc().toIso8601String(),
          'side': side,
          'feeding_method': feedingMethod,
          'amount_ml': amountMl,
          'diaper_wet': diaperWet,
          'diaper_dirty': diaperDirty,
          'temperature_c': temperatureC,
          'medicine_name': blankToNull(medicineName),
          'medicine_dose': blankToNull(medicineDose),
          'burped': burped,
          'vomited': vomited,
          'notes': blankToNull(notes),
          'metadata': metadata ?? <String, dynamic>{},
        })
        .select(columns)
        .single();
    return CareEvent.fromMap(Map<String, dynamic>.from(row));
  }

  Future<CareEvent> update({
    required String id,
    DateTime? startedAt,
    DateTime? endedAt,
    String? side,
    String? feedingMethod,
    double? amountMl,
    bool? diaperWet,
    bool? diaperDirty,
    double? temperatureC,
    String? medicineName,
    String? medicineDose,
    bool? burped,
    bool? vomited,
    String? notes,
    Map<String, dynamic>? metadata,
  }) async {
    final values = <String, dynamic>{
      if (startedAt != null) 'started_at': startedAt.toUtc().toIso8601String(),
      if (endedAt != null) 'ended_at': endedAt.toUtc().toIso8601String(),
      if (side != null) 'side': side,
      if (feedingMethod != null) 'feeding_method': feedingMethod,
      if (amountMl != null) 'amount_ml': amountMl,
      if (diaperWet != null) 'diaper_wet': diaperWet,
      if (diaperDirty != null) 'diaper_dirty': diaperDirty,
      if (temperatureC != null) 'temperature_c': temperatureC,
      if (medicineName != null) 'medicine_name': blankToNull(medicineName),
      if (medicineDose != null) 'medicine_dose': blankToNull(medicineDose),
      if (burped != null) 'burped': burped,
      if (vomited != null) 'vomited': vomited,
      'notes': blankToNull(notes),
      if (metadata != null) 'metadata': metadata,
    };
    final row = await _client
        .from('care_events')
        .update(values)
        .eq('id', id)
        .select(columns)
        .single();
    return CareEvent.fromMap(Map<String, dynamic>.from(row));
  }

  Future<void> delete(String id) async =>
      _client.from('care_events').delete().eq('id', id);
}
