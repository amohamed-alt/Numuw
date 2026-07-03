import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/care_event.dart';
import '../models/vaccination.dart';
import '../repositories/care_event_repository.dart';
import '../repositories/vaccination_repository.dart';
import '../state/app_preferences.dart';

class ReminderPlan {
  const ReminderPlan({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledAt,
    required this.payload,
  });

  final int id;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final String payload;
}

class ReminderPlanner {
  const ReminderPlanner._();

  static ReminderPlan? feeding({
    required String childId,
    required List<CareEvent> recentEvents,
    required DateTime now,
  }) {
    final feedings =
        recentEvents
            .where((event) => event.eventType == 'feeding' && !event.isPumping)
            .toList()
          ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    if (feedings.isEmpty) return null;
    final last = feedings.first.startedAt.toLocal();
    final intervals = <Duration>[];
    for (var i = 0; i < min(feedings.length - 1, 6); i++) {
      final newer = feedings[i].startedAt.toLocal();
      final older = feedings[i + 1].startedAt.toLocal();
      final interval = newer.difference(older);
      if (interval.inMinutes >= 30 && interval.inHours <= 8) {
        intervals.add(interval);
      }
    }
    final average = intervals.isEmpty
        ? const Duration(hours: 3)
        : Duration(
            minutes:
                intervals.fold<int>(0, (sum, item) => sum + item.inMinutes) ~/
                intervals.length,
          );
    final scheduled = last.add(average);
    if (!scheduled.isAfter(now.add(const Duration(minutes: 5)))) return null;
    return ReminderPlan(
      id: _id(childId, 11),
      title: 'تذكير الرضعة',
      body: 'اقترب وقت الرضعة القادمة حسب سجلات الرضاعة الأخيرة.',
      scheduledAt: scheduled,
      payload: 'feeding:$childId',
    );
  }

  static ReminderPlan? medicine({
    required String childId,
    required CareEvent event,
    required DateTime now,
  }) {
    if (event.eventType != 'medicine') return null;
    final scheduled = event.startedAt.toLocal().add(const Duration(hours: 8));
    if (!scheduled.isAfter(now.add(const Duration(minutes: 5)))) return null;
    final name = event.medicineName?.trim();
    return ReminderPlan(
      id: _id(childId, 22),
      title: 'تذكير الدواء',
      body: name == null || name.isEmpty
          ? 'راجعي موعد الدواء المسجل.'
          : 'راجعي موعد $name المسجل.',
      scheduledAt: scheduled,
      payload: 'medicine:$childId',
    );
  }

  static ReminderPlan? vaccination({
    required String childId,
    required Vaccination? next,
    required DateTime now,
  }) {
    final date = next?.scheduledDate?.toLocal();
    if (next == null || date == null) return null;
    final scheduled = DateTime(date.year, date.month, date.day, 9);
    if (!scheduled.isAfter(now.add(const Duration(minutes: 5)))) return null;
    return ReminderPlan(
      id: _id(childId, 33),
      title: 'تذكير التطعيم',
      body:
          'التطعيم القادم: ${next.name}${next.doseLabel == null ? '' : ' - ${next.doseLabel}'}.',
      scheduledAt: scheduled,
      payload: 'vaccination:$childId',
    );
  }

  static int _id(String childId, int salt) {
    var hash = salt;
    for (final unit in childId.codeUnits) {
      hash = 0x1fffffff & (hash * 31 + unit);
    }
    return hash;
  }
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: darwin);
    await _plugin.initialize(settings: settings);
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    _initialized = true;
  }

  Future<void> rescheduleForChild(String childId) async {
    await initialize();
    final prefs = AppPreferences.instance;
    if (prefs.feedingRemindersEnabled) {
      final events = await CareEventRepository().fetchRecent(
        childId,
        limit: 20,
      );
      await schedule(
        ReminderPlanner.feeding(
          childId: childId,
          recentEvents: events,
          now: DateTime.now(),
        ),
      );
    } else {
      await cancel(ReminderPlanner._id(childId, 11));
    }

    if (prefs.vaccinationRemindersEnabled) {
      final next = await VaccinationRepository().nextScheduled(childId);
      await schedule(
        ReminderPlanner.vaccination(
          childId: childId,
          next: next,
          now: DateTime.now(),
        ),
      );
    } else {
      await cancel(ReminderPlanner._id(childId, 33));
    }
  }

  Future<void> scheduleMedicineFromEvent(CareEvent event) async {
    if (!AppPreferences.instance.medicineRemindersEnabled) return;
    await initialize();
    await schedule(
      ReminderPlanner.medicine(
        childId: event.childId,
        event: event,
        now: DateTime.now(),
      ),
    );
  }

  @visibleForTesting
  Future<void> schedule(ReminderPlan? plan) async {
    if (plan == null) return;
    await _plugin.zonedSchedule(
      id: plan.id,
      title: plan.title,
      body: plan.body,
      scheduledDate: tz.TZDateTime.from(plan.scheduledAt, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'numuw_reminders',
          'تذكيرات نُمُوّ',
          channelDescription: 'تذكيرات الرضاعة والدواء والتطعيمات',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: plan.payload,
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id: id);
}
