import 'health_sources.dart';

enum GrowthIndicator {
  weightForAge,
  lengthHeightForAge,
  headCircumferenceForAge,
}

enum ChildSex { female, male }

class GrowthStandardMetadata {
  const GrowthStandardMetadata({
    required this.source,
    required this.indicators,
    required this.status,
    required this.disclaimerArabic,
  });

  final HealthSource source;
  final List<GrowthIndicator> indicators;
  final HealthContentStatus status;
  final String disclaimerArabic;

  bool get canDisplayCharts => status == HealthContentStatus.verified;
}

class LmsGrowthRow {
  const LmsGrowthRow({
    required this.indicator,
    required this.sex,
    required this.ageMonths,
    required this.l,
    required this.m,
    required this.s,
  });

  final GrowthIndicator indicator;
  final ChildSex sex;
  final int ageMonths;
  final double l;
  final double m;
  final double s;
}

class WhoGrowthStandards {
  const WhoGrowthStandards._();

  static final metadata = GrowthStandardMetadata(
    source: OfficialHealthSources.whoGrowth,
    indicators: const [
      GrowthIndicator.weightForAge,
      GrowthIndicator.lengthHeightForAge,
      GrowthIndicator.headCircumferenceForAge,
    ],
    status: HealthContentStatus.needsSourceExtraction,
    disclaimerArabic: HealthDisclaimer.growthArabic,
  );

  static const List<LmsGrowthRow> lmsRows = [];

  static LmsGrowthRow? rowFor({
    required GrowthIndicator indicator,
    required ChildSex sex,
    required int ageMonths,
  }) {
    for (final row in lmsRows) {
      if (row.indicator == indicator && row.sex == sex && row.ageMonths == ageMonths) {
        return row;
      }
    }
    return null;
  }
}
