import 'care_event.dart';
import 'growth_measurement.dart';

enum WeeklyComparisonTrend { increased, decreased, stable, insufficientData }

class WeeklyMetricComparison {
  const WeeklyMetricComparison({
    required this.currentValue,
    required this.previousValue,
    required this.difference,
    required this.trend,
    required this.message,
  });

  final double currentValue;
  final double previousValue;
  final double difference;
  final WeeklyComparisonTrend trend;
  final String message;
}

class WeeklyPeriodSummary {
  const WeeklyPeriodSummary({
    required this.start,
    required this.end,
    required this.sleepHours,
    required this.feedingCount,
    required this.pumpingMl,
    required this.latestGrowth,
  });

  final DateTime start;
  final DateTime end;
  final double sleepHours;
  final int feedingCount;
  final double pumpingMl;
  final GrowthMeasurement? latestGrowth;
}

class WeeklyChildSummary {
  const WeeklyChildSummary({
    required this.childId,
    required this.childName,
    required this.current,
    required this.previous,
    required this.sleepComparison,
    required this.feedingComparison,
    required this.pumpingComparison,
  });

  final String childId;
  final String childName;
  final WeeklyPeriodSummary current;
  final WeeklyPeriodSummary previous;
  final WeeklyMetricComparison sleepComparison;
  final WeeklyMetricComparison feedingComparison;
  final WeeklyMetricComparison pumpingComparison;

  GrowthMeasurement? get highlightedGrowth =>
      current.latestGrowth ?? previous.latestGrowth;

  String get headlineMetric {
    final growth = highlightedGrowth;
    if (growth?.weightKg != null) {
      return '${_trim(growth!.weightKg!)} كجم';
    }
    if (growth?.heightCm != null) {
      return '${_trim(growth!.heightCm!)} سم';
    }
    if (current.sleepHours > 0) return '${_trim(current.sleepHours)} ساعة نوم';
    if (current.feedingCount > 0) return '${current.feedingCount} رضعات';
    return 'أسبوع جديد';
  }

  String get headlineLabel {
    final growth = highlightedGrowth;
    if (growth?.weightKg != null) return 'آخر وزن مسجل';
    if (growth?.heightCm != null) return 'آخر طول مسجل';
    if (current.sleepHours > 0) return 'إجمالي النوم';
    if (current.feedingCount > 0) return 'عدد الرضعات';
    return 'ابدئي التسجيل';
  }

  static String _trim(double value) {
    if (value == value.roundToDouble()) return value.round().toString();
    return value.toStringAsFixed(1);
  }
}

class WeeklySummaryCalculator {
  const WeeklySummaryCalculator();

  WeeklyChildSummary calculate({
    required String childId,
    required String childName,
    required DateTime now,
    required List<CareEvent> events,
    required List<GrowthMeasurement> growthMeasurements,
  }) {
    final localNow = now.toLocal();
    final currentStart = localNow.subtract(const Duration(days: 7));
    final previousStart = currentStart.subtract(const Duration(days: 7));
    final currentEvents = _eventsBetween(events, currentStart, localNow);
    final previousEvents = _eventsBetween(events, previousStart, currentStart);
    final currentGrowth = _latestGrowthBetween(
      growthMeasurements,
      currentStart,
      localNow,
    );
    final previousGrowth = _latestGrowthBetween(
      growthMeasurements,
      previousStart,
      currentStart,
    );
    final current = WeeklyPeriodSummary(
      start: currentStart,
      end: localNow,
      sleepHours: _sleepHours(currentEvents, currentStart, localNow),
      feedingCount: _feedingCount(currentEvents),
      pumpingMl: _pumpingMl(currentEvents),
      latestGrowth: currentGrowth,
    );
    final previous = WeeklyPeriodSummary(
      start: previousStart,
      end: currentStart,
      sleepHours: _sleepHours(previousEvents, previousStart, currentStart),
      feedingCount: _feedingCount(previousEvents),
      pumpingMl: _pumpingMl(previousEvents),
      latestGrowth: previousGrowth,
    );
    return WeeklyChildSummary(
      childId: childId,
      childName: childName,
      current: current,
      previous: previous,
      sleepComparison: compare(
        currentValue: current.sleepHours,
        previousValue: previous.sleepHours,
        noun: 'النوم',
        unit: 'ساعة',
        precision: 1,
      ),
      feedingComparison: compare(
        currentValue: current.feedingCount.toDouble(),
        previousValue: previous.feedingCount.toDouble(),
        noun: 'الرضعات',
        unit: 'رضعة',
        precision: 0,
      ),
      pumpingComparison: compare(
        currentValue: current.pumpingMl,
        previousValue: previous.pumpingMl,
        noun: 'الشفط',
        unit: 'مل',
        precision: 0,
      ),
    );
  }

  static WeeklyMetricComparison compare({
    required double currentValue,
    required double previousValue,
    required String noun,
    required String unit,
    int precision = 0,
  }) {
    final difference = currentValue - previousValue;
    if (currentValue <= 0 && previousValue <= 0) {
      return WeeklyMetricComparison(
        currentValue: currentValue,
        previousValue: previousValue,
        difference: difference,
        trend: WeeklyComparisonTrend.insufficientData,
        message: 'سجّلي أسبوعًا آخر لعرض نمط $noun.',
      );
    }
    if (previousValue <= 0) {
      return WeeklyMetricComparison(
        currentValue: currentValue,
        previousValue: previousValue,
        difference: difference,
        trend: WeeklyComparisonTrend.insufficientData,
        message: 'بدأتِ تسجيل $noun هذا الأسبوع.',
      );
    }
    final percentage = difference / previousValue * 100;
    if (percentage.abs() < 5) {
      return WeeklyMetricComparison(
        currentValue: currentValue,
        previousValue: previousValue,
        difference: difference,
        trend: WeeklyComparisonTrend.stable,
        message: '$noun قريب من الأسبوع السابق.',
      );
    }
    final direction = difference > 0 ? 'أكثر' : 'أقل';
    return WeeklyMetricComparison(
      currentValue: currentValue,
      previousValue: previousValue,
      difference: difference,
      trend: difference > 0
          ? WeeklyComparisonTrend.increased
          : WeeklyComparisonTrend.decreased,
      message:
          '$noun هذا الأسبوع $direction بـ${_format(difference.abs(), precision)} $unit عن الأسبوع السابق.',
    );
  }

  List<CareEvent> _eventsBetween(
    List<CareEvent> events,
    DateTime start,
    DateTime end,
  ) => events
      .where((event) {
        final local = event.startedAt.toLocal();
        return !local.isBefore(start) && local.isBefore(end);
      })
      .toList(growable: false);

  GrowthMeasurement? _latestGrowthBetween(
    List<GrowthMeasurement> measurements,
    DateTime start,
    DateTime end,
  ) {
    final filtered = measurements.where((measurement) {
      final local = measurement.measuredAt.toLocal();
      return !local.isBefore(start) && local.isBefore(end);
    }).toList()..sort((a, b) => b.measuredAt.compareTo(a.measuredAt));
    return filtered.isEmpty ? null : filtered.first;
  }

  double _sleepHours(List<CareEvent> events, DateTime start, DateTime end) {
    var minutes = 0;
    for (final event in events.where((event) => event.eventType == 'sleep')) {
      final eventStart = event.startedAt.toLocal().isBefore(start)
          ? start
          : event.startedAt.toLocal();
      final rawEnd = event.endedAt?.toLocal() ?? end;
      final eventEnd = rawEnd.isAfter(end) ? end : rawEnd;
      final duration = eventEnd.difference(eventStart);
      if (!duration.isNegative) minutes += duration.inMinutes;
    }
    return minutes / 60;
  }

  int _feedingCount(List<CareEvent> events) => events
      .where((event) => event.eventType == 'feeding' && !event.isPumping)
      .length;

  double _pumpingMl(List<CareEvent> events) => events.fold<double>(
    0,
    (total, event) => total + (event.pumpedAmountMl ?? 0),
  );

  static String _format(double value, int precision) {
    if (precision == 0) return value.round().toString();
    return value.toStringAsFixed(precision);
  }
}
