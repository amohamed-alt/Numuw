import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/content/growth_math.dart';
import 'package:flutter_application_1/content/who_growth_standards.dart';

void main() {
  const row = LmsGrowthRow(
    indicator: GrowthIndicator.weightForAge,
    sex: ChildSex.female,
    ageMonths: 6,
    l: 1,
    m: 7.3,
    s: 0.12,
  );

  test('zScore returns zero when value equals m', () {
    expect(GrowthMath.zScore(row, 7.3), closeTo(0, 0.0001));
  });

  test('zScore supports l zero rows', () {
    const logRow = LmsGrowthRow(
      indicator: GrowthIndicator.lengthHeightForAge,
      sex: ChildSex.male,
      ageMonths: 12,
      l: 0,
      m: 75,
      s: 0.04,
    );

    expect(GrowthMath.zScore(logRow, 75), closeTo(0, 0.0001));
  });

  test('assess returns unavailable without a matching row', () {
    final result = GrowthMath.assess(
      indicator: GrowthIndicator.headCircumferenceForAge,
      sex: ChildSex.male,
      ageMonths: 4,
      value: 41,
      rows: const [],
    );

    expect(result.zScore, isNull);
    expect(result.band, GrowthRangeBand.unavailable);
  });

  test('assess picks matching row and categorizes bands', () {
    final result = GrowthMath.assess(
      indicator: GrowthIndicator.weightForAge,
      sex: ChildSex.female,
      ageMonths: 6,
      value: 7.3,
      rows: const [row],
    );

    expect(result.zScore, closeTo(0, 0.0001));
    expect(result.band, GrowthRangeBand.typical);
    expect(GrowthMath.bandFor(-3.2), GrowthRangeBand.veryLow);
    expect(GrowthMath.bandFor(-2.5), GrowthRangeBand.low);
    expect(GrowthMath.bandFor(2.5), GrowthRangeBand.high);
    expect(GrowthMath.bandFor(3.2), GrowthRangeBand.veryHigh);
  });
}
