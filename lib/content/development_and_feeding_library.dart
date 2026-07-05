import 'health_sources.dart';

class DevelopmentActivityBand {
  const DevelopmentActivityBand({
    required this.id,
    required this.fromMonths,
    required this.toMonths,
    required this.titleArabic,
    required this.summaryArabic,
    required this.activitiesArabic,
    required this.askDoctorIfArabic,
    required this.source,
    this.status = HealthContentStatus.needsClinicalReview,
  });

  final String id;
  final int fromMonths;
  final int toMonths;
  final String titleArabic;
  final String summaryArabic;
  final List<String> activitiesArabic;
  final List<String> askDoctorIfArabic;
  final HealthSource source;
  final HealthContentStatus status;

  bool includesAgeInMonths(int months) => months >= fromMonths && months <= toMonths;
}

class DevelopmentLibrary {
  const DevelopmentLibrary._();

  static HealthSource get source => OfficialHealthSources.cdcMilestones;

  static final List<DevelopmentActivityBand> bands = [
    DevelopmentActivityBand(
      id: '0-2m',
      fromMonths: 0,
      toMonths: 2,
      titleArabic: 'الهدوء، الصوت، والنظر القريب',
      summaryArabic: 'أنشطة قصيرة وهادئة مناسبة للبدايات الأولى مع متابعة أي قلق مع الطبيب.',
      activitiesArabic: const [
        'الكلام الهادئ أثناء الروتين اليومي.',
        'وقت بطن قصير جدًا والطفل مستيقظ وتحت المراقبة.',
        'تتبع الوجه أو لعبة آمنة قريبة ببطء.',
      ],
      askDoctorIfArabic: const [
        'إذا لاحظت الأسرة فقدان مهارة أو قلقًا واضحًا في التفاعل.',
      ],
      source: OfficialHealthSources.cdcMilestones,
    ),
    DevelopmentActivityBand(
      id: '3-5m',
      fromMonths: 3,
      toMonths: 5,
      titleArabic: 'الابتسامة، اليدين، وتتبع اللعبة',
      summaryArabic: 'اللعب المتكرر والقصير يساعد الأسرة على الملاحظة بدون ضغط على الطفل.',
      activitiesArabic: const [
        'تقليد الأصوات والانتظار لدور الطفل.',
        'تحريك لعبة آمنة ببطء ليتابعها بعينيه.',
        'إتاحة لمس ألعاب ناعمة وآمنة تحت المراقبة.',
      ],
      askDoctorIfArabic: const [
        'إذا كان هناك قلق مستمر في السمع أو النظر أو الحركة.',
      ],
      source: OfficialHealthSources.cdcMilestones,
    ),
    DevelopmentActivityBand(
      id: '6-8m',
      fromMonths: 6,
      toMonths: 8,
      titleArabic: 'الجلوس، الاستكشاف، وبداية الطعام',
      summaryArabic: 'مرحلة الاستكشاف تحتاج بيئة آمنة ومراقبة مستمرة.',
      activitiesArabic: const [
        'لعبة الاختفاء والظهور بقطعة قماش خفيفة.',
        'تسمية الأشياء حول الطفل بكلمات قصيرة.',
        'ألعاب آمنة بملمس مختلف تحت المراقبة.',
      ],
      askDoctorIfArabic: const [
        'إذا فقد الطفل مهارة كان يفعلها سابقًا أو ظهر قلق واضح.',
      ],
      source: OfficialHealthSources.cdcMilestones,
    ),
    DevelopmentActivityBand(
      id: '9-12m',
      fromMonths: 9,
      toMonths: 12,
      titleArabic: 'الإشارة، التقليد، والحركة',
      summaryArabic: 'الروتين اليومي فرصة للكلام والتقليد والحركة الآمنة.',
      activitiesArabic: const [
        'تشجيع التصفيق أو التلويح وتقليده.',
        'قراءة صور بسيطة وتسميتها.',
        'وضع لعبة قريبة لتشجيع الحركة الآمنة نحوها.',
      ],
      askDoctorIfArabic: const [
        'إذا كان هناك قلق واضح في التواصل أو الاستجابة أو الحركة.',
      ],
      source: OfficialHealthSources.cdcMilestones,
    ),
    DevelopmentActivityBand(
      id: '13-24m',
      fromMonths: 13,
      toMonths: 24,
      titleArabic: 'الكلمات الأولى والاستقلال البسيط',
      summaryArabic: 'اختيارات صغيرة ومهام آمنة تساعد الطفل على المشاركة.',
      activitiesArabic: const [
        'اختيار بسيط بين لعبتين أو قطعتين.',
        'أغنية قصيرة بحركات متكررة.',
        'مساعدة آمنة مثل وضع لعبة في صندوق.',
      ],
      askDoctorIfArabic: const [
        'إذا كان هناك قلق مستمر في التواصل أو الحركة أو فقدان مهارة.',
      ],
      source: OfficialHealthSources.cdcMilestones,
    ),
  ];

  static DevelopmentActivityBand? forAgeInMonths(int months) {
    for (final band in bands) {
      if (band.includesAgeInMonths(months)) return band;
    }
    return null;
  }
}

class ComplementaryFeedingLibrary {
  const ComplementaryFeedingLibrary._();

  static HealthSource get source => OfficialHealthSources.whoFeeding;

  static const List<String> sixMonthsArabic = [
    'ابدئي تدريجيًا عند عمر مناسب وبمتابعة الطبيب إذا كان لدى الطفل حالة خاصة.',
    'سجلي الطعام، القوام، والكمية ورد الفعل داخل نُمُوّ.',
    'اجعلي الطعام تحت مراقبة شخص بالغ دائمًا.',
    'راجعي الطبيب عند ظهور رد فعل مقلق أو صعوبة مستمرة في الأكل.',
  ];
}

int ageInCompletedMonths(DateTime birthDate, DateTime onDate) {
  var months = (onDate.year - birthDate.year) * 12 + onDate.month - birthDate.month;
  if (onDate.day < birthDate.day) months -= 1;
  return months < 0 ? 0 : months;
}
