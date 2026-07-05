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
    this.notes = const <String>[],
  });

  final String id;
  final String authority;
  final String title;
  final String url;
  final String versionLabel;
  final DateTime lastReviewed;
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

enum HealthContentStatus { verified, needsSourceExtraction, needsClinicalReview }

enum NumuwCountry {
  egypt('EG', 'مصر'),
  saudiArabia('SA', 'السعودية'),
  unitedArabEmirates('AE', 'الإمارات');

  const NumuwCountry(this.isoCode, this.arabicName);

  final String isoCode;
  final String arabicName;
}

class OfficialHealthSources {
  const OfficialHealthSources._();

  static final egyptVaccination = HealthSource(
    id: 'eg-mohp-vaccination',
    authority: 'وزارة الصحة والسكان المصرية',
    title: 'مصدر جدول تطعيمات الأطفال في مصر',
    url: 'https://www.mohp.gov.eg/',
    versionLabel: 'بانتظار استخراج جدول رسمي محدد من صفحة أو ملف الوزارة',
    lastReviewed: DateTime(2026, 7, 6),
  );

  static final saudiVaccination = HealthSource(
    id: 'sa-moh-vaccination',
    authority: 'وزارة الصحة السعودية',
    title: 'مصدر جدول التطعيمات الأساسية للأطفال في السعودية',
    url: 'https://www.moh.gov.sa/',
    versionLabel: 'بانتظار استخراج جدول رسمي محدد من صفحة أو ملف الوزارة',
    lastReviewed: DateTime(2026, 7, 6),
  );

  static final uaeVaccination = HealthSource(
    id: 'ae-mohap-vaccination',
    authority: 'وزارة الصحة ووقاية المجتمع في دولة الإمارات',
    title: 'مصدر البرنامج الوطني للتحصين في الإمارات',
    url: 'https://mohap.gov.ae/',
    versionLabel: 'بانتظار استخراج جدول رسمي محدد من صفحة أو ملف الوزارة',
    lastReviewed: DateTime(2026, 7, 6),
  );

  static final whoGrowth = HealthSource(
    id: 'who-child-growth-standards',
    authority: 'World Health Organization',
    title: 'WHO Child Growth Standards',
    url: 'https://www.who.int/tools/child-growth-standards',
    versionLabel: 'WHO standards released 27 April 2006; exact LMS table import pending',
    lastReviewed: DateTime(2026, 7, 6),
    notes: const [
      'Covers growth indicators such as length or height for age, weight for age, and head circumference for age up to 60 completed months.',
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
    title: 'Infant and young child feeding',
    url: 'https://www.who.int/news-room/fact-sheets/detail/infant-and-young-child-feeding',
    versionLabel: 'WHO fact sheet; Arabic localization review pending',
    lastReviewed: DateTime(2026, 7, 6),
  );

  static List<HealthSource> get all => [
        egyptVaccination,
        saudiVaccination,
        uaeVaccination,
        whoGrowth,
        cdcMilestones,
        whoFeeding,
      ];

  static HealthSource vaccinationSourceFor(NumuwCountry country) => switch (country) {
        NumuwCountry.egypt => egyptVaccination,
        NumuwCountry.saudiArabia => saudiVaccination,
        NumuwCountry.unitedArabEmirates => uaeVaccination,
      };
}
