import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/errors/app_error.dart';
import '../models/care_event.dart';
import '../models/dashboard_summary.dart';
import '../models/family_task.dart';
import '../models/pumping_analytics.dart';
import '../repositories/care_event_repository.dart';
import '../repositories/dashboard_repository.dart';
import '../repositories/family_task_repository.dart';
import '../services/notification_service.dart';
import 'app_events.dart';
import 'child_session.dart';
import 'log_timer_state.dart';

class NumuwAppState extends ChangeNotifier {
  NumuwAppState._({
    DashboardRepository? dashboardRepository,
    CareEventRepository? careEventRepository,
    FamilyTaskRepository? taskRepository,
  }) : _dashboardRepository = dashboardRepository ?? DashboardRepository(),
       _careEventRepository = careEventRepository ?? CareEventRepository(),
       _taskRepository = taskRepository ?? FamilyTaskRepository() {
    ChildSession.instance.addListener(_onChildChanged);
    AppEvents.instance.addListener(_onExternalEvent);
  }

  static final NumuwAppState instance = NumuwAppState._();

  final DashboardRepository _dashboardRepository;
  final CareEventRepository _careEventRepository;
  final FamilyTaskRepository _taskRepository;

  DashboardSummary? _dashboard;
  bool _dashboardLoading = false;
  Object? _dashboardError;
  DateTime? _lastDashboardRefresh;
  Future<DashboardSummary>? _dashboardInflight;
  int _dashboardRequestId = 0;
  int _seenCareVersion = 0;
  int _seenTaskVersion = 0;
  int _seenVaccinationVersion = 0;
  PumpingComparison? _pumpingComparison;
  bool _pumpingLoading = false;
  Object? _pumpingError;
  int _pumpingRequestId = 0;

  DashboardSummary? get dashboard => _withActiveSleep(_dashboard);
  bool get dashboardLoading => _dashboardLoading;
  Object? get dashboardError => _dashboardError;
  DateTime? get lastDashboardRefresh => _lastDashboardRefresh;
  PumpingComparison? get pumpingComparison => _pumpingComparison;
  bool get pumpingLoading => _pumpingLoading;
  Object? get pumpingError => _pumpingError;

  Future<DashboardSummary?> refreshDashboard({bool force = false}) async {
    final child = ChildSession.instance.selectedChild;
    if (child == null) {
      _dashboard = null;
      _dashboardError = const MissingChildException();
      _dashboardLoading = false;
      notifyListeners();
      return null;
    }
    if (!force && _dashboardInflight != null) return _dashboardInflight;

    final requestId = ++_dashboardRequestId;
    _dashboardLoading = true;
    _dashboardError = null;
    notifyListeners();

    final future = _dashboardRepository.load(child.id);
    _dashboardInflight = future;
    try {
      final summary = await future;
      if (requestId != _dashboardRequestId ||
          ChildSession.instance.selectedChild?.id != child.id) {
        return _dashboard;
      }
      _dashboard = summary;
      _lastDashboardRefresh = DateTime.now();
      _dashboardError = null;
      return summary;
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (requestId == _dashboardRequestId) _dashboardError = error;
      return _dashboard;
    } finally {
      if (requestId == _dashboardRequestId) {
        _dashboardLoading = false;
        _dashboardInflight = null;
        notifyListeners();
      }
    }
  }

  Future<CareEvent> saveCareEvent({
    required String eventType,
    required DateTime startedAt,
    DateTime? endedAt,
    String? side,
    String? feedingMethod,
    double? amountMl,
    bool? diaperWet,
    bool? diaperDirty,
    double? temperatureC,
    String? medicineName,
    String? medicineDose,
    bool? burped,
    bool? vomited,
    String? notes,
    Map<String, dynamic>? metadata,
  }) async {
    final child = ChildSession.instance.selectedChild;
    if (child == null) throw const MissingChildException();
    final saved = await _careEventRepository.insert(
      childId: child.id,
      eventType: eventType,
      startedAt: startedAt,
      endedAt: endedAt,
      side: side,
      feedingMethod: feedingMethod,
      amountMl: amountMl,
      diaperWet: diaperWet,
      diaperDirty: diaperDirty,
      temperatureC: temperatureC,
      medicineName: medicineName,
      medicineDose: medicineDose,
      burped: burped,
      vomited: vomited,
      notes: notes,
      metadata: metadata ?? <String, dynamic>{},
    );
    _applySavedCareEvent(saved);
    AppEvents.instance.careEventsChanged();
    if (saved.isPumping) unawaited(refreshPumpingComparison(force: true));
    if (saved.eventType == 'feeding' || saved.eventType == 'medicine') {
      unawaited(NotificationService.instance.rescheduleForChild(saved.childId));
    }
    if (saved.eventType == 'medicine') {
      unawaited(NotificationService.instance.scheduleMedicineFromEvent(saved));
    }
    return saved;
  }

  Future<CareEvent> updateCareEventFields({
    required CareEvent event,
    required Map<String, dynamic> values,
  }) async {
    final updated = await _careEventRepository.updateFields(
      id: event.id,
      values: values,
    );
    _applySavedCareEvent(updated);
    AppEvents.instance.careEventsChanged();
    if (event.isPumping || updated.isPumping) {
      unawaited(refreshPumpingComparison(force: true));
    }
    return updated;
  }

  Future<void> deleteCareEvent(CareEvent event) async {
    await _careEventRepository.delete(event.id);
    final current = _dashboard;
    if (current != null) {
      _dashboard = current.copyWith(
        recentEvents: current.recentEvents
            .where((item) => item.id != event.id)
            .toList(growable: false),
        clearLatestFeeding:
            current.latestFeeding?.id == event.id &&
            event.eventType == 'feeding',
        clearLatestDiaper:
            current.latestDiaper?.id == event.id && event.eventType == 'diaper',
      );
      notifyListeners();
    }
    AppEvents.instance.careEventsChanged();
    if (event.isPumping) unawaited(refreshPumpingComparison(force: true));
    unawaited(refreshDashboard(force: true));
  }

  Future<PumpingComparison?> refreshPumpingComparison({
    bool force = false,
  }) async {
    final child = ChildSession.instance.selectedChild;
    if (child == null) {
      _pumpingComparison = null;
      _pumpingError = const MissingChildException();
      _pumpingLoading = false;
      notifyListeners();
      return null;
    }
    if (_pumpingLoading && !force) return _pumpingComparison;
    final requestId = ++_pumpingRequestId;
    _pumpingLoading = true;
    _pumpingError = null;
    notifyListeners();
    try {
      final events = await _careEventRepository.fetchPumpingForComparison(
        child.id,
      );
      if (requestId != _pumpingRequestId ||
          ChildSession.instance.selectedChild?.id != child.id) {
        return _pumpingComparison;
      }
      _pumpingComparison = PumpingComparison.fromEvents(
        events,
        childId: child.id,
      );
      return _pumpingComparison;
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (requestId == _pumpingRequestId) _pumpingError = error;
      return _pumpingComparison;
    } finally {
      if (requestId == _pumpingRequestId) {
        _pumpingLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> completeTask(FamilyTask task, bool completed) async {
    await _taskRepository.setCompleted(task.id, completed);
    AppEvents.instance.tasksChanged();
    await refreshDashboard(force: true);
  }

  Future<void> vaccinationChanged() async {
    AppEvents.instance.vaccinationsChanged();
    final child = ChildSession.instance.selectedChild;
    if (child != null) {
      unawaited(NotificationService.instance.rescheduleForChild(child.id));
    }
    await refreshDashboard(force: true);
  }

  void _applySavedCareEvent(CareEvent event) {
    final current = _dashboard;
    if (current == null || current.selectedChildId != event.childId) {
      unawaited(refreshDashboard(force: true));
      return;
    }
    final recent = [
      event,
      ...current.recentEvents.where((item) => item.id != event.id),
    ].take(8).toList(growable: false);
    _dashboard = current.copyWith(
      recentEvents: recent,
      latestFeeding: event.eventType == 'feeding' ? event : null,
      latestDiaper: event.eventType == 'diaper' ? event : null,
      sleepToday: event.eventType == 'sleep'
          ? DashboardRepository.calculateSleepToday(
              [
                event,
                ...current.recentEvents.where(
                  (item) => item.eventType == 'sleep',
                ),
              ],
              DashboardRepository.localDayStart(),
              DashboardRepository.localDayStart().add(const Duration(days: 1)),
              DateTime.now(),
            )
          : current.sleepToday,
    );
    notifyListeners();
    if (event.eventType == 'sleep') unawaited(refreshDashboard(force: true));
  }

  void _onChildChanged() {
    _dashboardRequestId++;
    _dashboard = null;
    _dashboardError = null;
    _dashboardInflight = null;
    _pumpingComparison = null;
    _pumpingError = null;
    _pumpingRequestId++;
    notifyListeners();
    unawaited(refreshDashboard(force: true));
    unawaited(refreshPumpingComparison(force: true));
  }

  void _onExternalEvent() {
    final events = AppEvents.instance;
    if (events.careEventVersion != _seenCareVersion ||
        events.taskVersion != _seenTaskVersion ||
        events.vaccinationVersion != _seenVaccinationVersion) {
      _seenCareVersion = events.careEventVersion;
      _seenTaskVersion = events.taskVersion;
      _seenVaccinationVersion = events.vaccinationVersion;
      unawaited(refreshDashboard(force: true));
    }
  }

  DashboardSummary? _withActiveSleep(DashboardSummary? summary) {
    final child = ChildSession.instance.selectedChild;
    if (summary == null || child == null) return summary;
    final sleepStart = LogTimerState.instance.sleepStartForChild(child.id);
    if (sleepStart == null) return summary;
    final start = DashboardRepository.localDayStart();
    final end = start.add(const Duration(days: 1));
    final active = CareEvent(
      id: 'local-active-sleep',
      childId: child.id,
      createdBy: 'local',
      eventType: 'sleep',
      startedAt: sleepStart,
    );
    return summary.copyWith(
      sleepToday: DashboardRepository.calculateSleepToday(
        [
          active,
          ...summary.recentEvents.where((event) => event.eventType == 'sleep'),
        ],
        start,
        end,
        DateTime.now(),
      ),
    );
  }
}
