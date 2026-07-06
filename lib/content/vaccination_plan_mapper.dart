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
    final officialDoseId = record.officialDoseId?.trim();
    for (final dose in schedule.doses) {
      final matchesOfficialId = officialDoseId != null &&
          officialDoseId.isNotEmpty &&
          dose.id == officialDoseId;
      final matchesLabels = dose.vaccineNameArabic.trim() == record.name.trim() &&
          dose.doseLabelArabic.trim() == (record.doseLabel ?? '').trim();
      if (matchesOfficialId || matchesLabels) {
        return VaccinationRecord(
          doseId: dose.id,
          givenDate: record.administeredDate ?? record.scheduledDate ?? DateTime.now(),
          providerName: record.provider,
          notesArabic: record.notes,
          attachmentPath: record.cardImagePath,
        );
      }
    }
    return null;
  }
}
