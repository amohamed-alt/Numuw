class EgyptVaccinationScheduleItem {
  const EgyptVaccinationScheduleItem({
    required this.name,
    required this.doseLabel,
    required this.dueAgeDays,
  });

  final String name;
  final String doseLabel;
  final int dueAgeDays;
}

class EgyptVaccinationSchedule {
  const EgyptVaccinationSchedule._();

  static const sourceName =
      'Egyptian Health Council - جدول تطعيمات الأطفال الإجبارية';
  static const sourceUrl =
      'https://lms.ehc.gov.eg/lms/mod/book/view.php?chapterid=3425&id=570';

  static const items = <EgyptVaccinationScheduleItem>[
    EgyptVaccinationScheduleItem(
      name: 'كبدي ب رضع',
      doseLabel: 'جرعة الميلاد خلال أول 24 ساعة',
      dueAgeDays: 0,
    ),
    EgyptVaccinationScheduleItem(
      name: 'سابين',
      doseLabel: 'الجرعة الصفرية',
      dueAgeDays: 0,
    ),
    EgyptVaccinationScheduleItem(
      name: 'بي.سي.جي',
      doseLabel: 'جرعة الدرن',
      dueAgeDays: 0,
    ),
    EgyptVaccinationScheduleItem(
      name: 'سابين',
      doseLabel: 'الجرعة الأولى',
      dueAgeDays: 60,
    ),
    EgyptVaccinationScheduleItem(
      name: 'طعم الخماسي',
      doseLabel: 'الجرعة الأولى',
      dueAgeDays: 60,
    ),
    EgyptVaccinationScheduleItem(
      name: 'طعم سولك',
      doseLabel: 'الجرعة الأولى',
      dueAgeDays: 60,
    ),
    EgyptVaccinationScheduleItem(
      name: 'سابين',
      doseLabel: 'الجرعة الثانية',
      dueAgeDays: 120,
    ),
    EgyptVaccinationScheduleItem(
      name: 'طعم الخماسي',
      doseLabel: 'الجرعة الثانية',
      dueAgeDays: 120,
    ),
    EgyptVaccinationScheduleItem(
      name: 'طعم سولك',
      doseLabel: 'الجرعة الثانية',
      dueAgeDays: 120,
    ),
    EgyptVaccinationScheduleItem(
      name: 'سابين',
      doseLabel: 'الجرعة الثالثة',
      dueAgeDays: 180,
    ),
    EgyptVaccinationScheduleItem(
      name: 'طعم الخماسي',
      doseLabel: 'الجرعة الثالثة',
      dueAgeDays: 180,
    ),
    EgyptVaccinationScheduleItem(
      name: 'طعم سولك',
      doseLabel: 'الجرعة الثالثة',
      dueAgeDays: 180,
    ),
    EgyptVaccinationScheduleItem(
      name: 'سابين',
      doseLabel: 'الجرعة الرابعة',
      dueAgeDays: 270,
    ),
    EgyptVaccinationScheduleItem(
      name: 'سابين',
      doseLabel: 'الجرعة الخامسة',
      dueAgeDays: 365,
    ),
    EgyptVaccinationScheduleItem(
      name: 'ام ام ار الفيروسي',
      doseLabel: 'جرعة 12 شهر',
      dueAgeDays: 365,
    ),
    EgyptVaccinationScheduleItem(
      name: 'سابين',
      doseLabel: 'الجرعة المنشطة',
      dueAgeDays: 548,
    ),
    EgyptVaccinationScheduleItem(
      name: 'ام ام ار الفيروسي',
      doseLabel: 'جرعة 18 شهر',
      dueAgeDays: 548,
    ),
    EgyptVaccinationScheduleItem(
      name: 'الثلاثي البكتيري',
      doseLabel: 'الجرعة المنشطة',
      dueAgeDays: 548,
    ),
  ];

  static DateTime scheduledDate(DateTime birthDate, int dueAgeDays) {
    return DateTime(
      birthDate.year,
      birthDate.month,
      birthDate.day + dueAgeDays,
    );
  }
}
