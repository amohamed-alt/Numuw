/// Audited source metadata for Numuw health content.
///
/// This file is intentionally data-only and dependency-free. It does not provide
/// clinical instructions. Feature modules must show the disclaimer and must not
/// display country schedules or growth percentiles until the underlying rows are
/// extracted from the cited official source and reviewed.
class HealthSource {
  const HealthSource({
    required this.id,
    required this.authority,
    required this.title,
    required this.url,
    required this.versionLabel,
    required this.lastReviewed,
    this.countryIsoCode,
    this.languageCode = 'ar',
    this.effectiveDate,
    this.notes = const <String>[],
  });

  final String id;
  final String authority;
  final String title;
  final String url;
  final String versionLabel;
  final DateTime lastReviewed;
  final String? countryIsoCode;
  final String languageCode;
  final DateTime? effectiveDate;
  final List<String> notes;
}

class HealthDisclaimer {
  const HealthDisclaimer._();

  static const medicalArabic =
      'محتوى نُمُوّ للتثقيف والمتابعة فقط، ولا يشخّص ولا يستبدل الطبيب أو الجهة الصحية الرسمية في بلدك.';

  static const vaccinationArabic =
      'جداول التطعيمات قد تتغير حسب الدولة وحالة الطفل وتعليمات الطبيب. أكّدي الموعد مع الجهة الصحية الرسمية أو طبيب الأطفال.';

  static const growthArabic =
      'منحنيات النمو تساعد على المتابعة ولا تعني وحدها أن الطفل طبيعي أو غير طبيعي. راجعي الطبيب عند أي قلق أو تغيّر واضح في مسار النمو.';
}

enum HealthContentStatus {
  verified,
  needsSourceExtraction,
  needsClinicalReview,
  unavailable,
}

enum NumuwCountry {
  egypt('EG', 'مصر'),
  saudiArabia('SA', 'السعودية'),
  unitedArabEmirates('AE', 'الإمارات'),
  kuwait('KW', 'الكويت'),
  qatar('QA', 'قطر'),
  bahrain('BH', 'البحرين'),
  oman('OM', 'عُمان'),
  jordan('JO', 'الأردن'),
  lebanon('LB', 'لبنان'),
  iraq('IQ', 'العراق'),
  palestine('PS', 'فلسطين'),
  morocco('MA', 'المغرب'),
  algeria('DZ', 'الجزائر'),
  tunisia('TN', 'تونس'),
  libya('LY', 'ليبيا'),
  sudan('SD', 'السودان'),
  yemen('YE', 'اليمن'),
  syria('SY', 'سوريا'),
  mauritania('MR', 'موريتانيا');

  const NumuwCountry(this.isoCode, this.arabicName);

  final String isoCode;
  final String arabicName;

  static NumuwCountry? fromIsoCode(String? value) {
    final normalized = value?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty) return null;
    for (final country in values) {
      if (country.isoCode == normalized) return country;
    }
    return null;
  }
}

class OfficialHealthSources {
  const OfficialHealthSources._();

  static const _whoCountryScheduleUrl =
      'https://immunizationdata.who.int/global/wiise-detail-page/vaccination-schedule-for-country_name';

  static final Map<NumuwCountry, HealthSource> _vaccinationSources = {
    for (final country in NumuwCountry.values)
      country: _countryVaccinationSource(country),
  };

  static HealthSource _countryVaccinationSource(NumuwCountry country) {
    switch (country) {
      case NumuwCountry.egypt:
        return HealthSource(
          id: 'egypt-mohp-routine-immunization',
          authority: 'وزارة الصحة والسكان المصرية',
          title: 'الجدول القومي للتطعيمات الإجبارية للأطفال — مصر',
          url: 'https://www.mohp.gov.eg/',
          versionLabel:
              'مصدر وطني رسمي؛ استخراج الجرعات التفصيلية قيد المراجعة الطبية قبل العرض',
          lastReviewed: DateTime(2026, 7, 6),
          countryIsoCode: country.isoCode,
          notes: const [
            'لا تُعرض جرعات مصر داخل التطبيق قبل مطابقة الجدول الرسمي ومراجعته طبيًا.',
            'تُستخدم هذه البيانات كبيانات مصدرية فقط إلى أن تكتمل مراجعة الجرعات والتوقيتات.',
          ],
        );
      case NumuwCountry.saudiArabia:
        return HealthSource(
          id: 'saudi-moh-vaccination-schedule',
          authority: 'وزارة الصحة السعودية',
          title: 'جدول التطعيمات الأساسية — السعودية',
          url: 'https://www.moh.gov.sa/',
          versionLabel:
              'مصدر وطني رسمي؛ استخراج الجرعات التفصيلية قيد المراجعة الطبية قبل العرض',
          lastReviewed: DateTime(2026, 7, 6),
          countryIsoCode: country.isoCode,
          notes: const [
            'لا تُعرض جرعات السعودية داخل التطبيق قبل مطابقة جدول وزارة الصحة ومراجعته طبيًا.',
            'تُراجع أي تحديثات وطنية قبل تغيير المواعيد أو الجرعات.',
          ],
        );
      case NumuwCountry.unitedArabEmirates:
        return HealthSource(
          id: 'uae-mohap-national-immunization-program',
          authority: 'وزارة الصحة ووقاية المجتمع الإماراتية',
          title: 'البرنامج الوطني للتحصين — الإمارات',
          url: 'https://mohap.gov.ae/',
          versionLabel:
              'مصدر وطني رسمي؛ استخراج الجرعات التفصيلية قيد المراجعة الطبية قبل العرض',
          lastReviewed: DateTime(2026, 7, 6),
          countryIsoCode: country.isoCode,
          notes: const [
            'لا تُعرض جرعات الإمارات داخل التطبيق قبل مطابقة مصدر MOHAP ومراجعته طبيًا.',
            'قد تختلف بعض الخدمات حسب الإمارة أو جهة تقديم الخدمة الصحية.',
          ],
        );
      default:
        return HealthSource(
          id: 'who-national-schedule-${country.isoCode.toLowerCase()}',
          authority:
              'World Health Organization / national immunization reporting authority',
          title: 'الجدول الوطني للتطعيمات — ${country.arabicName}',
          url: _whoCountryScheduleUrl,
          versionLabel:
              'WHO country scheduler؛ استخراج الجرعات ومطابقتها مع المصدر الوطني قيد المراجعة',
          lastReviewed: DateTime(2026, 7, 6),
          countryIsoCode: country.isoCode,
          notes: [
            'يجب تطبيق مرشح الدولة ${country.isoCode} عند مراجعة المصدر.',
            'لا تُعرض جرعات داخل التطبيق قبل الاستخراج والمراجعة الطبية.',
            'تُراجع النسخة الوطنية أو وزارة الصحة المحلية قبل اعتماد أي تحديث.',
          ],
        );
    }
  }

  static HealthSource get egyptVaccination =>
      _vaccinationSources[NumuwCountry.egypt]!;
  static HealthSource get saudiVaccination =>
      _vaccinationSources[NumuwCountry.saudiArabia]!;
  static HealthSource get uaeVaccination =>
      _vaccinationSources[NumuwCountry.unitedArabEmirates]!;

  static final whoGrowth = HealthSource(
    id: 'who-child-growth-standards',
    authority: 'World Health Organization',
    title: 'WHO Child Growth Standards',
    url: 'https://www.who.int/tools/child-growth-standards/standards',
    versionLabel:
        'WHO standards for children from birth to 5 years; exact LMS table import pending',
    lastReviewed: DateTime(2026, 7, 6),
    notes: const [
      'Includes length or height for age, weight for age, weight for length or height, BMI for age, and head circumference for age.',
      'Sex-specific LMS tables must be imported and tested before percentile or z-score display.',
    ],
  );

  static final cdcMilestones = HealthSource(
    id: 'cdc-act-early',
    authority: 'Centers for Disease Control and Prevention',
    title: 'Learn the Signs. Act Early. Developmental Milestones',
    url: 'https://www.cdc.gov/act-early/',
    versionLabel: 'Public milestone resources; Arabic localization review pending',
    lastReviewed: DateTime(2026, 7, 6),
  );

  static final whoFeeding = HealthSource(
    id: 'who-iycf',
    authority: 'World Health Organization',
    title: 'Infant and young child feeding / Complementary feeding',
    url: 'https://www.who.int/health-topics/complementary-feeding',
    versionLabel:
        'WHO guidance for complementary feeding from around 6 months; Arabic localization review pending',
    lastReviewed: DateTime(2026, 7, 6),
  );

  static List<HealthSource> get all => [
        ..._vaccinationSources.values,
        whoGrowth,
        cdcMilestones,
        whoFeeding,
      ];

  static HealthSource vaccinationSourceFor(NumuwCountry country) =>
      _vaccinationSources[country]!;
}
