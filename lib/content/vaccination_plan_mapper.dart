import '../models/vaccination.dart';
import 'vaccination_records.dart';
import 'vaccination_schedule_catalog.dart';

class VaccinationPlanMapper {
  const VaccinationPlanMapper._();

  static VaccinationPlan buildPlan({
    required VaccinationScheduleDefinition schedule,
    required DateTime birthDate,
    required List<Vaccination> records,
    DateTime? today,
  }) {
    return VaccinationPlan(
      schedule: schedule,
      birthDate: birthDate,
      records: records
          .map((record) => toPlanRecord(record, schedule))
          .whereType<VaccinationRecord>()
          .toList(growable: false),
      today: today,
    );
  }

  static VaccinationRecord? toPlanRecord(
    Vaccination record,
    VaccinationScheduleDefinition schedule,
  ) {
    if (record.status != 'completed') return null;
    final doseId = record.officialDoseId ?? _matchDoseId(record, schedule);
    if (doseId == null) return null;
    return VaccinationRecord(
      doseId: doseId,
      givenDate: record.administeredDate ?? record.scheduledDate ?? DateTime.now(),
      providerName: record.provider,
      notesArabic: record.notes,
      attachmentPath: record.cardImagePath,
    );
  }

  static String? _matchDoseId(
    Vaccination record,
    VaccinationScheduleDefinition schedule,
  ) {
    final normalizedName = _normalize(record.name);
    final normalizedDose = _normalize(record.doseLabel ?? '');
    for (final dose in schedule.doses) {
      final sameName = _normalize(dose.vaccineNameArabic) == normalizedName;
      final sameLabel = _normalize(dose.doseLabelArabic) == normalizedDose;
      if (sameName && sameLabel) return dose.id;
    }
    return null;
  }

  static String _normalize(String value) => value
      .trim()
      .replaceAll('أ', 'ا')
      .replaceAll('إ', 'ا')
      .replaceAll('آ', 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه')
      .replaceAll(RegExp(r'\s+'), ' ')
      .toLowerCase();
}
