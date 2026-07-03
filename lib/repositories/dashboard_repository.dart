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

  static DateTime localDayStart([DateTime? value]) {
    final local = (value ?? DateTime.now()).toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  Future<DashboardSummary> load(String childId) async {
    final now = DateTime.now();
    final start = localDayStart(now);
    final end = start.add(const Duration(days: 1));
    final results = await Future.wait([
      _careEvents.fetchSleepOverlappingDay(childId, start, end),
      _careEvents.latestByType(childId, 'feeding'),
      _careEvents.latestByType(childId, 'diaper'),
      _vaccinations.nextScheduled(childId),
      _tasks.incomplete(childId),
      _careEvents.fetchRecent(childId, limit: 8),
    ]);
    final sleepEvents = results[0] as List<CareEvent>;
    return DashboardSummary(
      selectedChildId: childId,
      sleepToday: calculateSleepToday(sleepEvents, start, end, now),
      latestFeeding: results[1] as CareEvent?,
      latestDiaper: results[2] as CareEvent?,
      nextVaccination: results[3] as dynamic,
      incompleteTasks: results[4] as dynamic,
      recentEvents: results[5] as dynamic,
      lastRefresh: DateTime.now(),
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
      final rawStarted = event.startedAt.toLocal();
      final rawEnded = (event.endedAt ?? now).toLocal();
      if (rawEnded.isBefore(rawStarted)) continue;
      final started = rawStarted.isBefore(dayStart) ? dayStart : rawStarted;
      final ended = rawEnded.isAfter(dayEnd) ? dayEnd : rawEnded;
      if (ended.isAfter(started)) total += ended.difference(started);
    }
    return total;
  }
}
