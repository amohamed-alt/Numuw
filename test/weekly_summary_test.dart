import 'package:flutter_application_1/models/care_event.dart';
import 'package:flutter_application_1/models/growth_measurement.dart';
import 'package:flutter_application_1/models/weekly_child_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WeeklySummaryCalculator', () {
    const calculator = WeeklySummaryCalculator();
    final now = DateTime(2026, 7, 3, 12);

    test('calculates current and previous week totals', () {
      final summary = calculator.calculate(
        childId: 'child-1',
        childName: 'ليلى',
        now: now,
        events: [
          _sleep(now.subtract(const Duration(days: 1)), 120),
          _feeding(now.subtract(const Duration(days: 2))),
          _pumping(now.subtract(const Duration(days: 3)), 75),
          _sleep(now.subtract(const Duration(days: 8)), 60),
          _feeding(now.subtract(const Duration(days: 9))),
          _pumping(now.subtract(const Duration(days: 10)), 30),
          _feeding(now.subtract(const Duration(days: 15))),
        ],
        growthMeasurements: [
          _growth(now.subtract(const Duration(days: 2)), weightKg: 6.4),
        ],
      );

      expect(summary.current.sleepHours, 2);
      expect(summary.current.feedingCount, 1);
      expect(summary.current.pumpingMl, 75);
      expect(summary.previous.sleepHours, 1);
      expect(summary.previous.feedingCount, 1);
      expect(summary.previous.pumpingMl, 30);
      expect(summary.headlineMetric, '6.4 كجم');
    });

    test('does not count pumping as normal feeding', () {
      final summary = calculator.calculate(
        childId: 'child-1',
        childName: 'ليلى',
        now: now,
        events: [
          _feeding(now.subtract(const Duration(days: 1))),
          _legacyPumping(now.subtract(const Duration(days: 2)), 45),
          _pumping(now.subtract(const Duration(days: 3)), 60),
        ],
        growthMeasurements: const [],
      );

      expect(summary.current.feedingCount, 1);
      expect(summary.current.pumpingMl, 105);
    });

    test('returns insufficient data when both periods are empty', () {
      final comparison = WeeklySummaryCalculator.compare(
        currentValue: 0,
        previousValue: 0,
        noun: 'النوم',
        unit: 'ساعة',
        precision: 1,
      );

      expect(comparison.trend, WeeklyComparisonTrend.insufficientData);
      expect(comparison.message, contains('سجّلي أسبوعًا آخر'));
    });

    test('previous zero never generates infinity wording', () {
      final comparison = WeeklySummaryCalculator.compare(
        currentValue: 4,
        previousValue: 0,
        noun: 'النوم',
        unit: 'ساعة',
        precision: 1,
      );

      expect(comparison.trend, WeeklyComparisonTrend.insufficientData);
      expect(comparison.message, isNot(contains('Infinity')));
      expect(comparison.message, isNot(contains('100')));
    });

    test('detects increase, decrease, and stable trend', () {
      final increased = WeeklySummaryCalculator.compare(
        currentValue: 12,
        previousValue: 10,
        noun: 'النوم',
        unit: 'ساعة',
        precision: 1,
      );
      final decreased = WeeklySummaryCalculator.compare(
        currentValue: 8,
        previousValue: 10,
        noun: 'النوم',
        unit: 'ساعة',
        precision: 1,
      );
      final stable = WeeklySummaryCalculator.compare(
        currentValue: 10.4,
        previousValue: 10,
        noun: 'النوم',
        unit: 'ساعة',
        precision: 1,
      );

      expect(increased.trend, WeeklyComparisonTrend.increased);
      expect(decreased.trend, WeeklyComparisonTrend.decreased);
      expect(stable.trend, WeeklyComparisonTrend.stable);
    });

    test('ignores events outside the rolling 14 day window', () {
      final summary = calculator.calculate(
        childId: 'child-1',
        childName: 'ليلى',
        now: now,
        events: [
          _sleep(now.subtract(const Duration(days: 16)), 480),
          _feeding(now.subtract(const Duration(days: 20))),
          _pumping(now.subtract(const Duration(days: 21)), 200),
        ],
        growthMeasurements: const [],
      );

      expect(summary.current.sleepHours, 0);
      expect(summary.previous.sleepHours, 0);
      expect(summary.current.feedingCount, 0);
      expect(summary.current.pumpingMl, 0);
    });
  });
}

CareEvent _sleep(DateTime startedAt, int minutes) => CareEvent(
  id: 'sleep-${startedAt.microsecondsSinceEpoch}',
  childId: 'child-1',
  createdBy: 'user-1',
  eventType: 'sleep',
  startedAt: startedAt,
  endedAt: startedAt.add(Duration(minutes: minutes)),
);

CareEvent _feeding(DateTime startedAt) => CareEvent(
  id: 'feeding-${startedAt.microsecondsSinceEpoch}',
  childId: 'child-1',
  createdBy: 'user-1',
  eventType: 'feeding',
  startedAt: startedAt,
);

CareEvent _pumping(DateTime startedAt, double amountMl) => CareEvent(
  id: 'pumping-${startedAt.microsecondsSinceEpoch}',
  childId: 'child-1',
  createdBy: 'user-1',
  eventType: 'pumping',
  startedAt: startedAt,
  amountMl: amountMl,
);

CareEvent _legacyPumping(DateTime startedAt, double amountMl) => CareEvent(
  id: 'legacy-${startedAt.microsecondsSinceEpoch}',
  childId: 'child-1',
  createdBy: 'user-1',
  eventType: 'feeding',
  startedAt: startedAt,
  amountMl: amountMl,
  metadata: const {
    'feeding_methods': ['pumping'],
  },
);

GrowthMeasurement _growth(DateTime measuredAt, {double? weightKg}) =>
    GrowthMeasurement(
      id: 'growth-${measuredAt.microsecondsSinceEpoch}',
      childId: 'child-1',
      createdBy: 'user-1',
      measuredAt: measuredAt,
      weightKg: weightKg,
    );
