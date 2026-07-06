import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/content/growth_chart_series.dart';
import 'package:flutter_application_1/content/growth_math.dart';
import 'package:flutter_application_1/content/who_growth_standards.dart';
import 'package:flutter_application_1/models/growth_measurement.dart';

void main() {
  test('WHO LMS seed rows are source gated', () {
    expect(WhoGrowthStandards.lmsRows, isNotEmpty);
    expect(WhoGrowthStandards.metadata.canDisplayCharts, isFalse);
  });

  test('growth chart series calculates completed months and z score', () {
    final points = GrowthChartSeriesBuilder.build(
      indicator: GrowthIndicator.weightForAge,
      sex: ChildSex.female,
      birthDate: DateTime(2026, 1, 15),
      measurements: [
        GrowthMeasurement(
          id: 'g1',
          childId: 'child',
          createdBy: 'user',
          measuredAt: DateTime(2026, 7, 15),
          weightKg: 7.297,
        ),
      ],
    );

    expect(points.length, 1);
    expect(points.single.ageMonths, 6);
    expect(points.single.result.band, GrowthRangeBand.typical);
    expect(points.single.result.zScore, closeTo(0, 0.0001));
  });
}
