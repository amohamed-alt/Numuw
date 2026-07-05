import 'health_sources.dart';

class VaccineDoseDefinition {
  const VaccineDoseDefinition({
    required this.id,
    required this.vaccineNameArabic,
    required this.doseLabelArabic,
    required this.dueFromBirth,
    required this.sourceId,
    this.windowStart,
    this.windowEnd,
    this.notesArabic = const <String>[],
    this.status = HealthContentStatus.needsClinicalReview,
  });

  final String id;
  final String vaccineNameArabic;
  final String doseLabelArabic;
  final Duration dueFromBirth;
  final Duration? windowStart;
  final Duration? windowEnd;
  final String sourceId;
  final List<String> notesArabic;
  final HealthContentStatus status;

  DateTime dueDateFor(DateTime birthDate) => _dateOnly(birthDate.add(dueFromBirth));

  DateTime? windowStartFor(DateTime birthDate) =>
      windowStart == null ? null : _dateOnly(birthDate.add(windowStart!));

  DateTime? windowEndFor(DateTime birthDate) =>
      windowEnd == null ? null : _dateOnly(birthDate.add(windowEnd!));
}

class VaccinationScheduleDefinition {
  const VaccinationScheduleDefinition({
    required this.country,
    required this.source,
    required this.doses,
    this.status = HealthContentStatus.needsSourceExtraction,
  });

  final NumuwCountry country;
  final HealthSource source;
  final List<VaccineDoseDefinition> doses;
  final HealthContentStatus status;

  List<ScheduledDose> buildForBirthDate(
    DateTime birthDate, {
    DateTime? today,
    Set<String> completedDoseIds = const <String>{},
  }) {
    final now = _dateOnly(today ?? DateTime.now());
    return doses
        .map(
          (dose) => ScheduledDose(
            definition: dose,
            dueDate: dose.dueDateFor(birthDate),
            windowStart: dose.windowStartFor(birthDate),
            windowEnd: dose.windowEndFor(birthDate),
            completed: completedDoseIds.contains(dose.id),
            today: now,
          ),
        )
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }
}

class ScheduledDose {
  const ScheduledDose({
    required this.definition,
    required this.dueDate,
    required this.windowStart,
    required this.windowEnd,
    required this.completed,
    required this.today,
  });

  final VaccineDoseDefinition definition;
  final DateTime dueDate;
  final DateTime? windowStart;
  final DateTime? windowEnd;
  final bool completed;
  final DateTime today;

  bool get isUpcoming => !completed && dueDate.isAfter(today);
  bool get isDueToday => !completed && _sameDate(dueDate, today);
  bool get isOverdue => !completed && dueDate.isBefore(today);

  String get statusArabic {
    if (completed) return 'completed';
    if (isOverdue) return 'overdue';
    if (isDueToday) return 'today';
    return 'upcoming';
  }
}

class VaccinationScheduleCatalog {
  const VaccinationScheduleCatalog._();

  static final Map<NumuwCountry, VaccinationScheduleDefinition> schedules = {
    for (final country in NumuwCountry.values)
      country: VaccinationScheduleDefinition(
        country: country,
        source: OfficialHealthSources.vaccinationSourceFor(country),
        doses: const [],
        status: HealthContentStatus.needsSourceExtraction,
      ),
  };

  static VaccinationScheduleDefinition? forCountry(NumuwCountry country) => schedules[country];
}

DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

bool _sameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
