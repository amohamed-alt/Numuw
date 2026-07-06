import 'dart:math' as math;

import 'who_growth_standards.dart';

enum GrowthRangeBand {
  veryLow,
  low,
  typical,
  high,
  veryHigh,
  unavailable,
}

class GrowthMathResult {
  const GrowthMathResult({
    required this.indicator,
    required this.sex,
    required this.ageMonths,
    required this.value,
    required this.zScore,
    required this.band,
  });

  final GrowthIndicator indicator;
  final ChildSex sex;
  final int ageMonths;
  final double value;
  final double? zScore;
  final GrowthRangeBand band;

  bool get hasScore => zScore != null;

  String get bandArabic => switch (band) {
        GrowthRangeBand.veryLow => 'أقل بكثير من النطاق المرجعي.',
        GrowthRangeBand.low => 'أقل من النطاق المرجعي.',
        GrowthRangeBand.typical => 'داخل النطاق المرجعي.',
        GrowthRangeBand.high => 'أعلى من النطاق المرجعي.',
        GrowthRangeBand.veryHigh => 'أعلى بكثير من النطاق المرجعي.',
        GrowthRangeBand.unavailable => 'غير متاح حتى تكتمل جداول WHO الرسمية.',
      };
}

class GrowthMath {
  const GrowthMath._();

  static GrowthMathResult assess({
    required GrowthIndicator indicator,
    required ChildSex sex,
    required int ageMonths,
    required double value,
    List<LmsGrowthRow> rows = WhoGrowthStandards.lmsRows,
  }) {
    final row = rowFor(
      rows: rows,
      indicator: indicator,
      sex: sex,
      ageMonths: ageMonths,
    );
    final score = row == null || value <= 0 ? null : zScore(row, value);
    return GrowthMathResult(
      indicator: indicator,
      sex: sex,
      ageMonths: ageMonths,
      value: value,
      zScore: score,
      band: score == null ? GrowthRangeBand.unavailable : bandFor(score),
    );
  }

  static double zScore(LmsGrowthRow row, double value) {
    if (value <= 0 || row.m <= 0 || row.s <= 0) {
      throw ArgumentError('Growth values must be positive.');
    }
    if (row.l == 0) {
      return math.log(value / row.m) / row.s;
    }
    return (math.pow(value / row.m, row.l).toDouble() - 1) / (row.l * row.s);
  }

  static GrowthRangeBand bandFor(double zScore) {
    if (zScore < -3) return GrowthRangeBand.veryLow;
    if (zScore < -2) return GrowthRangeBand.low;
    if (zScore <= 2) return GrowthRangeBand.typical;
    if (zScore <= 3) return GrowthRangeBand.high;
    return GrowthRangeBand.veryHigh;
  }

  static LmsGrowthRow? rowFor({
    required List<LmsGrowthRow> rows,
    required GrowthIndicator indicator,
    required ChildSex sex,
    required int ageMonths,
  }) {
    for (final row in rows) {
      if (row.indicator == indicator && row.sex == sex && row.ageMonths == ageMonths) {
        return row;
      }
    }
    return null;
  }
}
