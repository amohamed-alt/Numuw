import 'care_event.dart';
import 'family_task.dart';
import 'vaccination.dart';

class DashboardSummary {
  const DashboardSummary({
    required this.sleepToday,
    this.latestFeeding,
    this.latestDiaper,
    this.nextVaccination,
    required this.incompleteTasks,
    required this.recentEvents,
  });

  final Duration sleepToday;
  final CareEvent? latestFeeding;
  final CareEvent? latestDiaper;
  final Vaccination? nextVaccination;
  final List<FamilyTask> incompleteTasks;
  final List<CareEvent> recentEvents;
}
