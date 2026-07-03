import 'care_event.dart';
import 'family_task.dart';
import 'vaccination.dart';

class DashboardSummary {
  const DashboardSummary({
    required this.selectedChildId,
    required this.sleepToday,
    this.latestFeeding,
    this.latestDiaper,
    this.nextVaccination,
    required this.incompleteTasks,
    required this.recentEvents,
    this.loading = false,
    this.lastRefresh,
    this.error,
  });

  final String selectedChildId;
  final Duration sleepToday;
  final CareEvent? latestFeeding;
  final CareEvent? latestDiaper;
  final Vaccination? nextVaccination;
  final List<FamilyTask> incompleteTasks;
  final List<CareEvent> recentEvents;
  final bool loading;
  final DateTime? lastRefresh;
  final Object? error;

  DashboardSummary copyWith({
    String? selectedChildId,
    Duration? sleepToday,
    CareEvent? latestFeeding,
    bool clearLatestFeeding = false,
    CareEvent? latestDiaper,
    bool clearLatestDiaper = false,
    Vaccination? nextVaccination,
    bool clearNextVaccination = false,
    List<FamilyTask>? incompleteTasks,
    List<CareEvent>? recentEvents,
    bool? loading,
    DateTime? lastRefresh,
    Object? error,
    bool clearError = false,
  }) => DashboardSummary(
    selectedChildId: selectedChildId ?? this.selectedChildId,
    sleepToday: sleepToday ?? this.sleepToday,
    latestFeeding: clearLatestFeeding
        ? null
        : latestFeeding ?? this.latestFeeding,
    latestDiaper: clearLatestDiaper ? null : latestDiaper ?? this.latestDiaper,
    nextVaccination: clearNextVaccination
        ? null
        : nextVaccination ?? this.nextVaccination,
    incompleteTasks: incompleteTasks ?? this.incompleteTasks,
    recentEvents: recentEvents ?? this.recentEvents,
    loading: loading ?? this.loading,
    lastRefresh: lastRefresh ?? this.lastRefresh,
    error: clearError ? null : error ?? this.error,
  );
}
