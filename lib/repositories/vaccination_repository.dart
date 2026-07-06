// ignore_for_file: prefer_initializing_formals

import 'package:supabase_flutter/supabase_flutter.dart';

import '../content/health_sources.dart';
import '../content/vaccination_schedule_catalog.dart';
import '../models/vaccination.dart';
import 'repo_utils.dart';

class VaccinationRepository {
  VaccinationRepository({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;
  SupabaseClient get _supabase => _client ?? Supabase.instance.client;
  static const columns =
      'id,child_id,created_by,name,official_dose_id,dose_label,scheduled_date,administered_date,provider,status,card_image_path,notes,source_name,source_url,created_at,updated_at';

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
    String? officialDoseId,
    String? doseLabel,
    DateTime? scheduledDate,
    DateTime? administeredDate,
    String? provider,
    String status = 'scheduled',
    String? notes,
    String? sourceName,
    String? sourceUrl,
  }) async {
    final row = await withRepositoryTimeout(
      _supabase
          .from('vaccinations')
          .insert({
            'child_id': childId,
            'created_by': currentUserId(),
            'name': name.trim(),
            'official_dose_id': blankToNull(officialDoseId),
            'dose_label': blankToNull(doseLabel),
            'scheduled_date': dateOnly(scheduledDate),
            'administered_date': dateOnly(administeredDate),
            'provider': blankToNull(provider),
            'status': status,
            'notes': blankToNull(notes),
            'source_name': blankToNull(sourceName),
            'source_url': blankToNull(sourceUrl),
          })
          .select(columns)
          .single(),
    );
    return Vaccination.fromMap(Map<String, dynamic>.from(row));
  }

  Future<int> seedCountryOfficialSchedule({
    required String childId,
    required DateTime birthDate,
    required NumuwCountry country,
  }) async {
    final schedule = VaccinationScheduleCatalog.forCountry(country);
    if (schedule == null || schedule.doses.isEmpty) return 0;

    final existing = await fetch(childId);
    final seededKeys = existing
        .where((item) => item.sourceUrl == schedule.source.url)
        .map((item) => _seedKey(item.name, item.doseLabel))
        .toSet();

    final rows = schedule.doses
        .where(
          (dose) => !seededKeys.contains(
            _seedKey(dose.vaccineNameArabic, dose.doseLabelArabic),
          ),
        )
        .map(
          (dose) => {
            'child_id': childId,
            'created_by': currentUserId(),
            'name': dose.vaccineNameArabic,
            'official_dose_id': dose.id,
            'dose_label': dose.doseLabelArabic,
            'scheduled_date': dateOnly(dose.dueDateFor(birthDate)),
            'status': 'scheduled',
            'source_name': schedule.source.authority,
            'source_url': schedule.source.url,
          },
        )
        .toList(growable: false);

    if (rows.isEmpty) return 0;
    await withRepositoryTimeout(_supabase.from('vaccinations').insert(rows));
    return rows.length;
  }

  Future<int> seedEgyptOfficialSchedule({
    required String childId,
    required DateTime birthDate,
  }) =>
      seedCountryOfficialSchedule(
        childId: childId,
        birthDate: birthDate,
        country: NumuwCountry.egypt,
      );

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
    String? officialDoseId,
    String? doseLabel,
    DateTime? scheduledDate,
    DateTime? administeredDate,
    String? provider,
    required String status,
    String? notes,
    String? sourceName,
    String? sourceUrl,
  }) async {
    final row = await withRepositoryTimeout(
      _supabase
          .from('vaccinations')
          .update({
            'name': name.trim(),
            'official_dose_id': blankToNull(officialDoseId),
            'dose_label': blankToNull(doseLabel),
            'scheduled_date': dateOnly(scheduledDate),
            'administered_date': dateOnly(administeredDate),
            'provider': blankToNull(provider),
            'status': status,
            'notes': blankToNull(notes),
            'source_name': blankToNull(sourceName),
            'source_url': blankToNull(sourceUrl),
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

String _seedKey(String name, String? doseLabel) =>
    '${name.trim()}|${(doseLabel ?? '').trim()}';
