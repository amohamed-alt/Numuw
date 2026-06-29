import '../models/care_event.dart';
import '../models/dashboard_summary.dart';
import 'care_event_repository.dart';
import 'family_task_repository.dart';
import 'vaccination_repository.dart';

class DashboardRepository {
  DashboardRepository({
    CareEventRepository? careEvents,
    FamilyTaskRepository? tasks,
    VaccinationRepository? vaccinations,
  }) : _careEvents = careEvents ?? CareEventRepository(),
       _tasks = tasks ?? FamilyTaskRepository(),
       _vaccinations = vaccinations ?? VaccinationRepository();

  final CareEventRepository _careEvents;
  final FamilyTaskRepository _tasks;
  final VaccinationRepository _vaccinations;

  Future<DashboardSummary> load(String childId) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final results = await Future.wait([
      _careEvents.fetchBetween(childId, start, end),
      _careEvents.latestByType(childId, 'feeding'),
      _careEvents.latestByType(childId, 'diaper'),
      _vaccinations.nextScheduled(childId),
      _tasks.incomplete(childId),
      _careEvents.fetchRecent(childId, limit: 8),
    ]);
    final todayEvents = results[0] as List<CareEvent>;
    return DashboardSummary(
      sleepToday: calculateSleepToday(todayEvents, start, end, now),
      latestFeeding: results[1] as CareEvent?,
      latestDiaper: results[2] as CareEvent?,
      nextVaccination: results[3] as dynamic,
      incompleteTasks: results[4] as dynamic,
      recentEvents: results[5] as dynamic,
    );
  }

  static Duration calculateSleepToday(
    List<CareEvent> events,
    DateTime dayStart,
    DateTime dayEnd,
    DateTime now,
  ) {
    var total = Duration.zero;
    for (final event in events.where((event) => event.eventType == 'sleep')) {
      final started = event.startedAt.isBefore(dayStart)
          ? dayStart
          : event.startedAt;
      final endedRaw = event.endedAt ?? now;
      final ended = endedRaw.isAfter(dayEnd) ? dayEnd : endedRaw;
      if (ended.isAfter(started)) total += ended.difference(started);
    }
    return total;
  }
}
