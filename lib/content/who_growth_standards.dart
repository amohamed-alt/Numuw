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
    status: HealthContentStatus.needsClinicalReview,
    disclaimerArabic: HealthDisclaimer.growthArabic,
  );

  static const List<LmsGrowthRow> lmsRows = [
    LmsGrowthRow(indicator: GrowthIndicator.weightForAge, sex: ChildSex.female, ageMonths: 0, l: 0.3809, m: 3.2322, s: 0.14171),
    LmsGrowthRow(indicator: GrowthIndicator.weightForAge, sex: ChildSex.female, ageMonths: 6, l: -0.0756, m: 7.297, s: 0.12204),
    LmsGrowthRow(indicator: GrowthIndicator.weightForAge, sex: ChildSex.male, ageMonths: 0, l: 0.3487, m: 3.3464, s: 0.14602),
    LmsGrowthRow(indicator: GrowthIndicator.weightForAge, sex: ChildSex.male, ageMonths: 6, l: 0.1257, m: 7.934, s: 0.10958),
    LmsGrowthRow(indicator: GrowthIndicator.lengthHeightForAge, sex: ChildSex.female, ageMonths: 0, l: 1, m: 49.1477, s: 0.0379),
    LmsGrowthRow(indicator: GrowthIndicator.lengthHeightForAge, sex: ChildSex.male, ageMonths: 0, l: 1, m: 49.8842, s: 0.03795),
    LmsGrowthRow(indicator: GrowthIndicator.headCircumferenceForAge, sex: ChildSex.female, ageMonths: 0, l: 1, m: 33.8787, s: 0.03496),
    LmsGrowthRow(indicator: GrowthIndicator.headCircumferenceForAge, sex: ChildSex.male, ageMonths: 0, l: 1, m: 34.4618, s: 0.03686),
  ];

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
