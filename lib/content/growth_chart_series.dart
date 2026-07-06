import '../models/growth_measurement.dart';
import 'growth_math.dart';
import 'who_growth_standards.dart';

class GrowthChartPoint {
  const GrowthChartPoint({
    required this.measurement,
    required this.ageMonths,
    required this.value,
    required this.result,
  });

  final GrowthMeasurement measurement;
  final int ageMonths;
  final double value;
  final GrowthMathResult result;
}

class GrowthChartSeriesBuilder {
  const GrowthChartSeriesBuilder._();

  static List<GrowthChartPoint> build({
    required GrowthIndicator indicator,
    required ChildSex sex,
    required DateTime birthDate,
    required List<GrowthMeasurement> measurements,
  }) {
    final sorted = [...measurements]..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
    final points = <GrowthChartPoint>[];
    for (final measurement in sorted) {
      final value = _valueFor(indicator, measurement);
      if (value == null || value <= 0) continue;
      final ageMonths = completedMonthsBetween(birthDate, measurement.measuredAt);
      points.add(
        GrowthChartPoint(
          measurement: measurement,
          ageMonths: ageMonths,
          value: value,
          result: GrowthMath.assess(
            indicator: indicator,
            sex: sex,
            ageMonths: ageMonths,
            value: value,
          ),
        ),
      );
    }
    return points;
  }

  static int completedMonthsBetween(DateTime birthDate, DateTime measuredAt) {
    var months = (measuredAt.year - birthDate.year) * 12 + measuredAt.month - birthDate.month;
    if (measuredAt.day < birthDate.day) months -= 1;
    return months < 0 ? 0 : months;
  }

  static double? _valueFor(GrowthIndicator indicator, GrowthMeasurement item) {
    if (indicator == GrowthIndicator.weightForAge) return item.weightKg;
    if (indicator == GrowthIndicator.lengthHeightForAge) return item.heightCm;
    return item.headCircumferenceCm;
  }
}
