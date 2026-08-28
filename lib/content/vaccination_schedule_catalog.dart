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

  bool get hasExtractedDoses => doses.isNotEmpty;

  bool get canSeedUserRecords =>
      hasExtractedDoses &&
      doses.every((dose) => dose.status != HealthContentStatus.unavailable);

  String get availabilityArabic {
    if (doses.isEmpty) {
      return 'مصدر الدولة محفوظ، والجرعات التفصيلية لم تُستخرج بعد للمراجعة الطبية.';
    }
    if (status == HealthContentStatus.verified) {
      return 'جدول مستخرج ومراجع، مع ضرورة تأكيد الموعد مع الطبيب أو الجهة الرسمية.';
    }
    return 'جدول مستخرج كمحتوى مساعد وقيد المراجعة الطبية قبل اعتباره نهائيًا.';
  }

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
    if (completed) return 'مكتمل';
    if (isOverdue) return 'متأخر';
    if (isDueToday) return 'اليوم';
    return 'قادم';
  }
}

class VaccinationScheduleCatalog {
  const VaccinationScheduleCatalog._();

  static final Map<NumuwCountry, VaccinationScheduleDefinition> schedules = {
    for (final country in NumuwCountry.values)
      country: _definitionFor(country),
  };

  static VaccinationScheduleDefinition? forCountry(NumuwCountry country) => schedules[country];

  static List<VaccinationScheduleDefinition> get all =>
      NumuwCountry.values.map((country) => schedules[country]!).toList(growable: false);

  static VaccinationScheduleDefinition _definitionFor(NumuwCountry country) {
    final source = OfficialHealthSources.vaccinationSourceFor(country);
    if (country == NumuwCountry.egypt) {
      return VaccinationScheduleDefinition(
        country: country,
        source: source,
        doses: _egyptDoses(source.id),
        status: HealthContentStatus.needsClinicalReview,
      );
    }

    return VaccinationScheduleDefinition(
      country: country,
      source: source,
      doses: const [],
      status: HealthContentStatus.needsSourceExtraction,
    );
  }

  static List<VaccineDoseDefinition> _egyptDoses(String sourceId) => [
        _egyptDose(
          id: 'eg-birth-hepb',
          name: 'كبدي ب رضع',
          label: 'جرعة الميلاد خلال أول 24 ساعة',
          days: 0,
          sourceId: sourceId,
          notes: const ['تُراجع مع وحدة الرعاية أو طبيب الأطفال عند وجود موانع أو ظرف خاص.'],
        ),
        _egyptDose(
          id: 'eg-birth-opv0',
          name: 'سابين',
          label: 'الجرعة الصفرية',
          days: 0,
          sourceId: sourceId,
        ),
        _egyptDose(
          id: 'eg-birth-bcg',
          name: 'بي.سي.جي',
          label: 'جرعة الدرن',
          days: 0,
          sourceId: sourceId,
        ),
        _egyptDose(
          id: 'eg-2m-opv1',
          name: 'سابين',
          label: 'الجرعة الأولى',
          days: 60,
          sourceId: sourceId,
        ),
        _egyptDose(
          id: 'eg-2m-penta1',
          name: 'طعم الخماسي',
          label: 'الجرعة الأولى',
          days: 60,
          sourceId: sourceId,
        ),
        _egyptDose(
          id: 'eg-2m-ipv1',
          name: 'طعم سولك',
          label: 'الجرعة الأولى',
          days: 60,
          sourceId: sourceId,
        ),
        _egyptDose(
          id: 'eg-4m-opv2',
          name: 'سابين',
          label: 'الجرعة الثانية',
          days: 120,
          sourceId: sourceId,
        ),
        _egyptDose(
          id: 'eg-4m-penta2',
          name: 'طعم الخماسي',
          label: 'الجرعة الثانية',
          days: 120,
          sourceId: sourceId,
        ),
        _egyptDose(
          id: 'eg-4m-ipv2',
          name: 'طعم سولك',
          label: 'الجرعة الثانية',
          days: 120,
          sourceId: sourceId,
        ),
        _egyptDose(
          id: 'eg-6m-opv3',
          name: 'سابين',
          label: 'الجرعة الثالثة',
          days: 180,
          sourceId: sourceId,
        ),
        _egyptDose(
          id: 'eg-6m-penta3',
          name: 'طعم الخماسي',
          label: 'الجرعة الثالثة',
          days: 180,
          sourceId: sourceId,
        ),
        _egyptDose(
          id: 'eg-6m-ipv3',
          name: 'طعم سولك',
          label: 'الجرعة الثالثة',
          days: 180,
          sourceId: sourceId,
        ),
        _egyptDose(
          id: 'eg-9m-opv4',
          name: 'سابين',
          label: 'الجرعة الرابعة',
          days: 270,
          sourceId: sourceId,
        ),
        _egyptDose(
          id: 'eg-12m-opv5',
          name: 'سابين',
          label: 'الجرعة الخامسة',
          days: 365,
          sourceId: sourceId,
        ),
        _egyptDose(
          id: 'eg-12m-mmr1',
          name: 'ام ام ار الفيروسي',
          label: 'جرعة 12 شهر',
          days: 365,
          sourceId: sourceId,
        ),
        _egyptDose(
          id: 'eg-18m-opv-booster',
          name: 'سابين',
          label: 'الجرعة المنشطة',
          days: 548,
          sourceId: sourceId,
        ),
        _egyptDose(
          id: 'eg-18m-mmr2',
          name: 'ام ام ار الفيروسي',
          label: 'جرعة 18 شهر',
          days: 548,
          sourceId: sourceId,
        ),
        _egyptDose(
          id: 'eg-18m-dpt-booster',
          name: 'الثلاثي البكتيري',
          label: 'الجرعة المنشطة',
          days: 548,
          sourceId: sourceId,
        ),
      ];
}

VaccineDoseDefinition _egyptDose({
  required String id,
  required String name,
  required String label,
  required int days,
  required String sourceId,
  List<String> notes = const <String>[],
}) =>
    VaccineDoseDefinition(
      id: id,
      vaccineNameArabic: name,
      doseLabelArabic: label,
      dueFromBirth: Duration(days: days),
      windowStart: days == 0 ? Duration.zero : Duration(days: days - 7),
      windowEnd: Duration(days: days + 30),
      sourceId: sourceId,
      notesArabic: notes,
      status: HealthContentStatus.needsClinicalReview,
    );

DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

bool _sameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
