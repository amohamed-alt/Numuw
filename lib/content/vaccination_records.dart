import 'vaccination_schedule_catalog.dart';

/// User-entered vaccination record.
///
/// This stores what the caregiver confirms. It deliberately does not infer that
/// a child is medically protected and does not replace a clinician or official
/// immunization registry.
class VaccinationRecord {
  const VaccinationRecord({
    required this.doseId,
    required this.givenDate,
    this.providerName,
    this.batchNumber,
    this.notesArabic,
    this.attachmentPath,
  });

  final String doseId;
  final DateTime givenDate;
  final String? providerName;
  final String? batchNumber;
  final String? notesArabic;
  final String? attachmentPath;
}

class VaccinationPlan {
  const VaccinationPlan({
    required this.schedule,
    required this.birthDate,
    this.records = const <VaccinationRecord>[],
    this.today,
  });

  final VaccinationScheduleDefinition schedule;
  final DateTime birthDate;
  final List<VaccinationRecord> records;
  final DateTime? today;

  Set<String> get completedDoseIds => records.map((record) => record.doseId).toSet();

  bool get hasOfficialSchedule => schedule.doses.isNotEmpty;

  String get sourceSummaryArabic =>
      '${schedule.source.authority} · ${schedule.source.versionLabel}';

  List<ScheduledDose> get scheduledDoses => schedule.buildForBirthDate(
        birthDate,
        today: today,
        completedDoseIds: completedDoseIds,
      );

  ScheduledDose? get nextDose {
    final pending = scheduledDoses.where((dose) => !dose.completed).toList()
      ..sort((a, b) {
        final overdueCompare = _priority(a).compareTo(_priority(b));
        if (overdueCompare != 0) return overdueCompare;
        return a.dueDate.compareTo(b.dueDate);
      });

    return pending.isEmpty ? null : pending.first;
  }

  List<ScheduledDose> get overdueDoses =>
      scheduledDoses.where((dose) => dose.isOverdue && !dose.completed).toList();

  List<ScheduledDose> get dueNowDoses => scheduledDoses
      .where((dose) => !dose.completed && (dose.isOverdue || dose.isDueToday))
      .toList(growable: false);

  List<ScheduledDose> get upcomingDoses => scheduledDoses
      .where((dose) => !dose.completed && dose.isUpcoming)
      .toList(growable: false);

  List<ScheduledDose> get reminderCandidates => scheduledDoses
      .where((dose) => !dose.completed && (dose.isOverdue || dose.isDueToday || dose.isUpcoming))
      .toList();

  VaccinationPlan copyWithRecord(VaccinationRecord record) => VaccinationPlan(
        schedule: schedule,
        birthDate: birthDate,
        records: [
          ...records.where((item) => item.doseId != record.doseId),
          record,
        ],
        today: today,
      );
}

int _priority(ScheduledDose dose) {
  if (dose.isOverdue) return 0;
  if (dose.isDueToday) return 1;
  return 2;
}
