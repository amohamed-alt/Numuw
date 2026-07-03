// ignore_for_file: prefer_initializing_formals

import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/egypt_vaccination_schedule.dart';
import '../models/vaccination.dart';
import 'repo_utils.dart';

class VaccinationRepository {
  VaccinationRepository({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;
  SupabaseClient get _supabase => _client ?? Supabase.instance.client;
  static const columns =
      'id,child_id,created_by,name,dose_label,scheduled_date,administered_date,provider,status,card_image_path,source_name,source_url,created_at,updated_at';

  Future<List<Vaccination>> fetch(String childId) async {
    final rows = await withRepositoryTimeout(
      _supabase
          .from('vaccinations')
          .select(columns)
          .eq('child_id', childId)
          .order('scheduled_date'),
    );
    return _mapRows(rows);
  }

  Future<Vaccination?> nextScheduled(String childId) async {
    final today = DateTime.now();
    final rows = await withRepositoryTimeout(
      _supabase
          .from('vaccinations')
          .select(columns)
          .eq('child_id', childId)
          .eq('status', 'scheduled')
          .gte('scheduled_date', dateOnly(today)!)
          .order('scheduled_date')
          .limit(1),
    );
    final list = rows as List;
    if (list.isEmpty) return null;
    return Vaccination.fromMap(Map<String, dynamic>.from(list.first as Map));
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
    final row = await withRepositoryTimeout(
      _supabase
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
          .single(),
    );
    return Vaccination.fromMap(Map<String, dynamic>.from(row));
  }

  Future<void> seedEgyptOfficialSchedule({
    required String childId,
    required DateTime birthDate,
  }) async {
    final existing = await fetch(childId);
    final seededKeys = existing
        .where((item) => item.sourceUrl == EgyptVaccinationSchedule.sourceUrl)
        .map((item) => '${item.name}|${item.doseLabel}')
        .toSet();
    final rows = EgyptVaccinationSchedule.items
        .where((item) => !seededKeys.contains('${item.name}|${item.doseLabel}'))
        .map(
          (item) => {
            'child_id': childId,
            'created_by': currentUserId(),
            'name': item.name,
            'dose_label': item.doseLabel,
            'scheduled_date': dateOnly(
              EgyptVaccinationSchedule.scheduledDate(
                birthDate,
                item.dueAgeDays,
              ),
            ),
            'status': 'scheduled',
            'source_name': EgyptVaccinationSchedule.sourceName,
            'source_url': EgyptVaccinationSchedule.sourceUrl,
          },
        )
        .toList();
    if (rows.isEmpty) return;
    await withRepositoryTimeout(_supabase.from('vaccinations').insert(rows));
  }

  Future<void> updateStatus(String id, String status) => withRepositoryTimeout(
    _supabase
        .from('vaccinations')
        .update({
          'status': status,
          'administered_date': status == 'completed'
              ? dateOnly(DateTime.now())
              : null,
        })
        .eq('id', id),
  );

  Future<void> delete(String id) => withRepositoryTimeout(
    _supabase.from('vaccinations').delete().eq('id', id),
  );

  Future<Vaccination> update({
    required String id,
    required String name,
    String? doseLabel,
    DateTime? scheduledDate,
    DateTime? administeredDate,
    String? provider,
    required String status,
  }) async {
    final row = await withRepositoryTimeout(
      _supabase
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
          .single(),
    );
    return Vaccination.fromMap(Map<String, dynamic>.from(row));
  }

  List<Vaccination> _mapRows(Object? rows) => (rows as List)
      .map((row) => Vaccination.fromMap(Map<String, dynamic>.from(row as Map)))
      .toList();
}
