import 'care_event.dart';

enum PumpingTrend { increased, decreased, stable, insufficientData }

class PumpingPeriodStats {
  const PumpingPeriodStats({
    required this.periodStart,
    required this.periodEnd,
    required this.totalMl,
    required this.sessionCount,
    required this.averagePerSessionMl,
    required this.dailyAverageMl,
    required this.highestDayMl,
    required this.highestDayDate,
    required this.dailyTotals,
  });

  final DateTime periodStart;
  final DateTime periodEnd;
  final double totalMl;
  final int sessionCount;
  final double averagePerSessionMl;
  final double dailyAverageMl;
  final double highestDayMl;
  final DateTime? highestDayDate;
  final Map<DateTime, double> dailyTotals;
}

class PumpingComparison {
  const PumpingComparison({
    required this.currentPeriod,
    required this.previousPeriod,
    required this.differenceMl,
    required this.percentageChange,
    required this.trend,
    required this.hasEnoughData,
  });

  final PumpingPeriodStats currentPeriod;
  final PumpingPeriodStats previousPeriod;
  final double differenceMl;
  final double? percentageChange;
  final PumpingTrend trend;
  final bool hasEnoughData;

  static PumpingComparison fromEvents(
    List<CareEvent> events, {
    DateTime? now,
    String? childId,
  }) {
    final localNow = (now ?? DateTime.now()).toLocal();
    final currentStart = localNow.subtract(const Duration(days: 7));
    final previousStart = currentStart.subtract(const Duration(days: 7));
    final scoped = events
        .where((event) {
          if (childId != null && event.childId != childId) return false;
          if (!event.isPumping) return false;
          final amount = event.pumpedAmountMl;
          if (amount == null || amount <= 0) return false;
          final localStart = event.startedAt.toLocal();
          return !localStart.isBefore(previousStart) &&
              localStart.isBefore(localNow);
        })
        .toList(growable: false);

    final current = _statsFor(scoped, currentStart, localNow);
    final previous = _statsFor(scoped, previousStart, currentStart);
    final difference = current.totalMl - previous.totalMl;
    final percentage = previous.totalMl > 0
        ? (difference / previous.totalMl) * 100
        : null;
    final totalSessions = current.sessionCount + previous.sessionCount;
    final enough = totalSessions >= 2 && current.totalMl + previous.totalMl > 0;
    final trend = _trend(
      currentTotal: current.totalMl,
      previousTotal: previous.totalMl,
      percentage: percentage,
      enough: enough,
    );

    return PumpingComparison(
      currentPeriod: current,
      previousPeriod: previous,
      differenceMl: difference,
      percentageChange: percentage,
      trend: trend,
      hasEnoughData: trend != PumpingTrend.insufficientData,
    );
  }

  static PumpingPeriodStats _statsFor(
    List<CareEvent> events,
    DateTime start,
    DateTime end,
  ) {
    final dailyTotals = <DateTime, double>{};
    for (
      var day = _dayStart(start);
      day.isBefore(end);
      day = day.add(const Duration(days: 1))
    ) {
      dailyTotals[day] = 0;
    }

    var total = 0.0;
    var count = 0;
    for (final event in events) {
      final localStart = event.startedAt.toLocal();
      if (localStart.isBefore(start) || !localStart.isBefore(end)) continue;
      final amount = event.pumpedAmountMl;
      if (amount == null || amount <= 0) continue;
      final day = _dayStart(localStart);
      dailyTotals[day] = (dailyTotals[day] ?? 0) + amount;
      total += amount;
      count++;
    }

    DateTime? highestDay;
    var highest = 0.0;
    dailyTotals.forEach((day, value) {
      if (value > highest) {
        highest = value;
        highestDay = day;
      }
    });

    return PumpingPeriodStats(
      periodStart: start,
      periodEnd: end,
      totalMl: total,
      sessionCount: count,
      averagePerSessionMl: count == 0 ? 0 : total / count,
      dailyAverageMl: total / 7,
      highestDayMl: highest,
      highestDayDate: highestDay,
      dailyTotals: Map.unmodifiable(dailyTotals),
    );
  }

  static PumpingTrend _trend({
    required double currentTotal,
    required double previousTotal,
    required double? percentage,
    required bool enough,
  }) {
    if (!enough || (currentTotal == 0 && previousTotal == 0)) {
      return PumpingTrend.insufficientData;
    }
    if (previousTotal == 0 && currentTotal > 0) {
      return PumpingTrend.insufficientData;
    }
    if (percentage == null) return PumpingTrend.insufficientData;
    if (percentage >= 5) return PumpingTrend.increased;
    if (percentage <= -5) return PumpingTrend.decreased;
    return PumpingTrend.stable;
  }

  static DateTime _dayStart(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
