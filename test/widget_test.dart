import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/core/formatters/arabic_formatters.dart';
import 'package:flutter_application_1/core/errors/app_error.dart';
import 'package:flutter_application_1/core/numuw_app.dart';
import 'package:flutter_application_1/data/egypt_vaccination_schedule.dart';
import 'package:flutter_application_1/models/care_event.dart';
import 'package:flutter_application_1/models/child_guardian.dart';
import 'package:flutter_application_1/models/child_profile.dart';
import 'package:flutter_application_1/models/pumping_analytics.dart';
import 'package:flutter_application_1/models/vaccination.dart';
import 'package:flutter_application_1/repositories/dashboard_repository.dart';
import 'package:flutter_application_1/repositories/family_task_repository.dart';
import 'package:flutter_application_1/screens/auth/sign_in_screen.dart';
import 'package:flutter_application_1/screens/auth/sign_up_screen.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/screens/main_shell.dart';
import 'package:flutter_application_1/screens/pumping_screen.dart';
import 'package:flutter_application_1/screens/quick_log_screen.dart';
import 'package:flutter_application_1/services/notification_service.dart';
import 'package:flutter_application_1/state/child_session.dart';
import 'package:flutter_application_1/state/log_timer_state.dart';

void main() {
  test('Arabic age formatter shows weeks and days', () {
    final child = ChildProfile(
      id: '1',
      createdBy: 'u1',
      name: 'سارة',
      stage: 'born',
      birthDate: DateTime(2026, 1, 1),
      gender: 'female',
      feedingType: 'breast',
    );
    expect(
      ArabicFormatters.age(child, DateTime(2026, 1, 17)),
      '2 أسابيع و2 أيام',
    );
  });

  test('ChildProfile mapping handles nullable fields', () {
    final child = ChildProfile.fromMap({
      'id': 'c1',
      'created_by': 'u1',
      'name': 'ليان',
      'stage': 'pregnancy',
      'birth_date': null,
      'due_date': '2026-08-10',
      'gender': 'unspecified',
      'feeding_type': 'not_set',
      'blood_type': null,
      'birth_weight_kg': null,
    });
    expect(child.name, 'ليان');
    expect(child.stage, 'pregnancy');
    expect(child.dueDate, isNotNull);
  });

  test('ChildGuardian mapping accepts RPC display name and email', () {
    final guardian = ChildGuardian.fromMap({
      'child_id': 'c1',
      'user_id': 'u2',
      'role': 'guardian',
      'display_name': 'خالة ليان',
      'email': 'aunt@example.com',
      'created_at': '2026-07-03T10:00:00Z',
    });

    expect(guardian.displayName, 'خالة ليان');
    expect(guardian.email, 'aunt@example.com');
    expect(guardian.label, 'خالة ليان');
  });

  test('CareEvent mapping handles feeding fields', () {
    final event = CareEvent.fromMap({
      'id': 'e1',
      'child_id': 'c1',
      'created_by': 'u1',
      'event_type': 'feeding',
      'started_at': '2026-06-29T10:00:00Z',
      'ended_at': '2026-06-29T10:20:00Z',
      'side': 'right',
      'feeding_method': 'breast',
      'amount_ml': 80,
      'burped': true,
      'vomited': false,
    });
    expect(event.eventType, 'feeding');
    expect(event.amountMl, 80);
    expect(event.burped, true);
  });

  test('New pumping event parsing exposes pumped amount', () {
    final event = _pumping(
      'p1',
      DateTime(2026, 7, 1, 10),
      amount: 75,
      metadata: {'quantity_mode': 'total'},
    );

    expect(event.isPumping, isTrue);
    expect(event.pumpedAmountMl, 75);
  });

  test('Split pumping amounts calculate the stored total', () {
    final event = _pumping(
      'p2',
      DateTime(2026, 7, 1, 10),
      amount: 75,
      metadata: {
        'quantity_mode': 'split',
        'left_amount_ml': 35,
        'right_amount_ml': 40,
      },
    );

    expect(event.amountMl, 75);
    expect(event.leftPumpedAmountMl, 35);
    expect(event.rightPumpedAmountMl, 40);
    expect(event.hasSplitPumpingQuantity, isTrue);
  });

  test('Missing split pumping metadata does not crash', () {
    final event = _pumping('p3', DateTime(2026, 7, 1, 10), amount: 30);

    expect(event.leftPumpedAmountMl, isNull);
    expect(event.rightPumpedAmountMl, isNull);
    expect(event.hasSplitPumpingQuantity, isFalse);
  });

  test('Pumping metadata parses int, double, and numeric string values', () {
    final event = _pumping(
      'p4',
      DateTime(2026, 7, 1, 10),
      amount: 42,
      metadata: {'left_amount_ml': 15, 'right_amount_ml': '27.5'},
    );

    expect(event.leftPumpedAmountMl, 15);
    expect(event.rightPumpedAmountMl, 27.5);
  });

  test('Legacy feeding pumping record remains compatible', () {
    final event = CareEvent(
      id: 'legacy',
      childId: 'c1',
      createdBy: 'u1',
      eventType: 'feeding',
      startedAt: DateTime(2026, 7, 1, 10),
      amountMl: 60,
      metadata: {
        'feeding_methods': ['pumping'],
      },
    );

    expect(event.isPumping, isTrue);
    expect(event.pumpedAmountMl, 60);
  });

  test('Normal feeding events are not counted as pumping', () {
    final event = CareEvent(
      id: 'feed',
      childId: 'c1',
      createdBy: 'u1',
      eventType: 'feeding',
      startedAt: DateTime(2026, 7, 1, 10),
      amountMl: 60,
      metadata: {
        'feeding_methods': ['breast'],
      },
    );

    expect(event.isPumping, isFalse);
    expect(event.pumpedAmountMl, isNull);
  });

  test(
    'Pumping comparison calculates current and previous seven-day totals',
    () {
      final now = DateTime(2026, 7, 15, 12);
      final comparison = PumpingComparison.fromEvents(
        [
          _pumping('c1', now.subtract(const Duration(days: 1)), amount: 100),
          _pumping('c2', now.subtract(const Duration(days: 6)), amount: 50),
          _pumping('p1', now.subtract(const Duration(days: 8)), amount: 40),
          _pumping('p2', now.subtract(const Duration(days: 13)), amount: 20),
        ],
        now: now,
        childId: 'c1',
      );

      expect(comparison.currentPeriod.totalMl, 150);
      expect(comparison.previousPeriod.totalMl, 60);
    },
  );

  test('Pumping comparison detects percentage increase', () {
    final now = DateTime(2026, 7, 15, 12);
    final comparison = PumpingComparison.fromEvents(
      [
        _pumping('c1', now.subtract(const Duration(days: 1)), amount: 120),
        _pumping('p1', now.subtract(const Duration(days: 8)), amount: 100),
      ],
      now: now,
      childId: 'c1',
    );

    expect(comparison.percentageChange, 20);
    expect(comparison.trend, PumpingTrend.increased);
  });

  test('Pumping comparison detects percentage decrease', () {
    final now = DateTime(2026, 7, 15, 12);
    final comparison = PumpingComparison.fromEvents(
      [
        _pumping('c1', now.subtract(const Duration(days: 1)), amount: 80),
        _pumping('p1', now.subtract(const Duration(days: 8)), amount: 100),
      ],
      now: now,
      childId: 'c1',
    );

    expect(comparison.percentageChange, -20);
    expect(comparison.trend, PumpingTrend.decreased);
  });

  test('Pumping comparison treats changes within five percent as stable', () {
    final now = DateTime(2026, 7, 15, 12);
    final comparison = PumpingComparison.fromEvents(
      [
        _pumping('c1', now.subtract(const Duration(days: 1)), amount: 104),
        _pumping('p1', now.subtract(const Duration(days: 8)), amount: 100),
      ],
      now: now,
      childId: 'c1',
    );

    expect(comparison.trend, PumpingTrend.stable);
  });

  test('Previous total zero does not generate infinity', () {
    final now = DateTime(2026, 7, 15, 12);
    final comparison = PumpingComparison.fromEvents(
      [
        _pumping('c1', now.subtract(const Duration(days: 1)), amount: 100),
        _pumping('c2', now.subtract(const Duration(days: 2)), amount: 20),
      ],
      now: now,
      childId: 'c1',
    );

    expect(comparison.percentageChange, isNull);
    expect(comparison.trend, PumpingTrend.insufficientData);
  });

  test('Both pumping periods empty return insufficient data', () {
    final comparison = PumpingComparison.fromEvents(
      const [],
      now: DateTime(2026, 7, 15, 12),
      childId: 'c1',
    );

    expect(comparison.trend, PumpingTrend.insufficientData);
    expect(comparison.currentPeriod.totalMl, 0);
    expect(comparison.previousPeriod.totalMl, 0);
  });

  test('Invalid zero or negative pumping amounts are ignored', () {
    final now = DateTime(2026, 7, 15, 12);
    final comparison = PumpingComparison.fromEvents(
      [
        _pumping('zero', now.subtract(const Duration(days: 1)), amount: 0),
        _pumping('bad', now.subtract(const Duration(days: 2)), amount: -10),
        _pumping('ok', now.subtract(const Duration(days: 3)), amount: 20),
      ],
      now: now,
      childId: 'c1',
    );

    expect(comparison.currentPeriod.totalMl, 20);
    expect(comparison.currentPeriod.sessionCount, 1);
  });

  test('Events outside the fourteen-day pumping range are ignored', () {
    final now = DateTime(2026, 7, 15, 12);
    final comparison = PumpingComparison.fromEvents(
      [
        _pumping('old', now.subtract(const Duration(days: 15)), amount: 200),
        _pumping('ok', now.subtract(const Duration(days: 1)), amount: 20),
      ],
      now: now,
      childId: 'c1',
    );

    expect(comparison.currentPeriod.totalMl, 20);
    expect(comparison.previousPeriod.totalMl, 0);
  });

  test('Local day aggregation sums multiple pumping sessions per day', () {
    final now = DateTime(2026, 7, 15, 12);
    final day = DateTime(2026, 7, 14);
    final comparison = PumpingComparison.fromEvents(
      [
        _pumping('a', DateTime(2026, 7, 14, 8), amount: 25),
        _pumping('b', DateTime(2026, 7, 14, 18), amount: 35),
        _pumping('p', now.subtract(const Duration(days: 8)), amount: 10),
      ],
      now: now,
      childId: 'c1',
    );

    expect(comparison.currentPeriod.dailyTotals[day], 60);
    expect(comparison.currentPeriod.highestDayMl, 60);
  });

  test('Different children are never mixed in pumping analytics', () {
    final now = DateTime(2026, 7, 15, 12);
    final comparison = PumpingComparison.fromEvents(
      [
        _pumping('mine', now.subtract(const Duration(days: 1)), amount: 25),
        _pumping(
          'other',
          now.subtract(const Duration(days: 1)),
          amount: 500,
          childId: 'c2',
        ),
      ],
      now: now,
      childId: 'c1',
    );

    expect(comparison.currentPeriod.totalMl, 25);
  });

  test('Feeding reminder uses average interval and ignores pumping', () {
    final now = DateTime(2026, 7, 3, 12);
    final plan = ReminderPlanner.feeding(
      childId: 'c1',
      now: now,
      recentEvents: [
        _feeding('f3', DateTime(2026, 7, 3, 10)),
        _pumping('p1', DateTime(2026, 7, 3, 9), amount: 50),
        _feeding('f2', DateTime(2026, 7, 3, 7)),
        _feeding('f1', DateTime(2026, 7, 3, 4)),
      ],
    );

    expect(plan, isNotNull);
    expect(plan!.scheduledAt, DateTime(2026, 7, 3, 13));
    expect(plan.payload, 'feeding:c1');
  });

  test('Medicine reminder is scheduled from medicine event', () {
    final event = CareEvent(
      id: 'm1',
      childId: 'c1',
      createdBy: 'u1',
      eventType: 'medicine',
      startedAt: DateTime(2026, 7, 3, 10),
      medicineName: 'دواء',
    );
    final plan = ReminderPlanner.medicine(
      childId: 'c1',
      event: event,
      now: DateTime(2026, 7, 3, 12),
    );

    expect(plan, isNotNull);
    expect(plan!.scheduledAt, DateTime(2026, 7, 3, 18));
    expect(plan.payload, 'medicine:c1');
  });

  test('Vaccination reminder is scheduled at nine on due date', () {
    final plan = ReminderPlanner.vaccination(
      childId: 'c1',
      now: DateTime(2026, 7, 3, 12),
      next: Vaccination(
        id: 'v1',
        childId: 'c1',
        createdBy: 'u1',
        name: 'تطعيم',
        scheduledDate: DateTime(2026, 7, 10),
        status: 'scheduled',
      ),
    );

    expect(plan, isNotNull);
    expect(plan!.scheduledAt, DateTime(2026, 7, 10, 9));
    expect(plan.payload, 'vaccination:c1');
  });

  test('Egypt official vaccination schedule has source and expected size', () {
    expect(EgyptVaccinationSchedule.items, hasLength(18));
    expect(
      EgyptVaccinationSchedule.sourceName,
      contains('Egyptian Health Council'),
    );
    expect(EgyptVaccinationSchedule.sourceUrl, contains('ehc.gov.eg'));
  });

  test(
    'Egypt official vaccination due dates are calculated from birth date',
    () {
      final birth = DateTime(2026, 1, 1, 18);

      expect(
        EgyptVaccinationSchedule.scheduledDate(birth, 0),
        DateTime(2026, 1, 1),
      );
      expect(
        EgyptVaccinationSchedule.scheduledDate(birth, 60),
        DateTime(2026, 3, 2),
      );
      expect(
        EgyptVaccinationSchedule.scheduledDate(birth, 548),
        DateTime(2027, 7, 3),
      );
    },
  );

  test('CareEvent mapping never emits null metadata', () {
    final event = CareEvent.fromMap({
      'id': 'e2',
      'child_id': 'c1',
      'created_by': 'u1',
      'event_type': 'note',
      'started_at': '2026-06-29T10:00:00Z',
      'metadata': null,
    });

    expect(event.metadata, <String, dynamic>{});
    expect(event.toMap()['metadata'], <String, dynamic>{});
  });

  test('CareEvent mapping keeps multiple feeding methods metadata', () {
    final event = CareEvent.fromMap({
      'id': 'e3',
      'child_id': 'c1',
      'created_by': 'u1',
      'event_type': 'feeding',
      'started_at': '2026-06-29T10:00:00Z',
      'feeding_method': 'breast',
      'metadata': {
        'feeding_methods': ['breast', 'bottle'],
      },
    });

    expect(event.metadata?['feeding_methods'], ['breast', 'bottle']);
    expect(event.toMap()['metadata'], isA<Map<String, dynamic>>());
  });

  test('readableError returns Arabic timeout message', () {
    expect(
      readableError(const RequestTimeoutException()),
      'استغرق الطلب وقتًا طويلًا. تحققي من اتصالك وحاولي مرة أخرى.',
    );
    expect(
      readableError(Exception('Request timed out')),
      'استغرق الطلب وقتًا طويلًا. تحققي من اتصالك وحاولي مرة أخرى.',
    );
  });

  test(
    'Old feeding_method remains available without feeding_methods metadata',
    () {
      final event = CareEvent.fromMap({
        'id': 'e4',
        'child_id': 'c1',
        'created_by': 'u1',
        'event_type': 'feeding',
        'started_at': '2026-06-29T10:00:00Z',
        'feeding_method': 'bottle',
        'metadata': <String, dynamic>{},
      });

      expect(event.feedingMethod, 'bottle');
      expect(event.metadata, <String, dynamic>{});
    },
  );

  test('Dashboard sleep calculation sums multiple sessions today', () {
    final start = DateTime(2026, 6, 29);
    final end = start.add(const Duration(days: 1));
    final now = DateTime(2026, 6, 29, 10);
    final events = [
      _sleep('1', DateTime(2026, 6, 29, 1), DateTime(2026, 6, 29, 3)),
      _sleep('2', DateTime(2026, 6, 29, 4), DateTime(2026, 6, 29, 5)),
    ];
    expect(
      DashboardRepository.calculateSleepToday(events, start, end, now),
      const Duration(hours: 3),
    );
  });

  test('Dashboard sleep calculation clips sessions crossing midnight', () {
    final start = DateTime(2026, 6, 29);
    final end = start.add(const Duration(days: 1));
    final now = DateTime(2026, 6, 29, 10);
    final events = [
      _sleep('1', DateTime(2026, 6, 28, 22), DateTime(2026, 6, 29, 2)),
      _sleep('2', DateTime(2026, 6, 29, 23), DateTime(2026, 6, 30, 2)),
    ];
    expect(
      DashboardRepository.calculateSleepToday(events, start, end, now),
      const Duration(hours: 3),
    );
  });

  test('Dashboard sleep calculation counts active sleep until now', () {
    final start = DateTime(2026, 6, 29);
    final end = start.add(const Duration(days: 1));
    final events = [_sleep('active', DateTime(2026, 6, 29, 1), null)];
    expect(
      DashboardRepository.calculateSleepToday(
        events,
        start,
        end,
        DateTime(2026, 6, 29, 2, 30),
      ),
      const Duration(hours: 1, minutes: 30),
    );
  });

  test('Dashboard sleep calculation ignores invalid negative duration', () {
    final start = DateTime(2026, 6, 29);
    final end = start.add(const Duration(days: 1));
    final events = [
      _sleep('bad', DateTime(2026, 6, 29, 4), DateTime(2026, 6, 29, 3)),
    ];
    expect(
      DashboardRepository.calculateSleepToday(
        events,
        start,
        end,
        DateTime(2026, 6, 29, 5),
      ),
      Duration.zero,
    );
  });

  test('Dashboard sleep calculation handles UTC-to-local boundary safely', () {
    final start = DateTime(2026, 6, 29);
    final end = start.add(const Duration(days: 1));
    final events = [
      _sleep(
        'utc',
        DateTime.utc(2026, 6, 28, 22).toLocal(),
        DateTime.utc(2026, 6, 29, 1).toLocal(),
      ),
    ];
    final total = DashboardRepository.calculateSleepToday(
      events,
      start,
      end,
      DateTime(2026, 6, 29, 4),
    );
    expect(total >= Duration.zero, isTrue);
  });

  test('Task title validation rejects malformed titles', () {
    expect(isValidTaskTitle(null), isFalse);
    expect(isValidTaskTitle(''), isFalse);
    expect(isValidTaskTitle('   '), isFalse);
    expect(isValidTaskTitle('.'), isFalse);
    expect(isValidTaskTitle('..'), isFalse);
    expect(isValidTaskTitle('...'), isFalse);
    expect(isValidTaskTitle('!!!'), isFalse);
    expect(isValidTaskTitle('موعد الطبيب'), isTrue);
  });

  test('Selected-child state propagation notifies listeners', () {
    var calls = 0;
    final child1 = _child('c1');
    final child2 = _child('c2');
    void listener() => calls++;
    ChildSession.instance.addListener(listener);
    addTearDown(() {
      ChildSession.instance.removeListener(listener);
      ChildSession.instance.clear();
    });

    ChildSession.instance.setChildren([child1, child2]);
    ChildSession.instance.selectChild(child2);

    expect(ChildSession.instance.selectedChild?.id, 'c2');
    expect(calls, greaterThanOrEqualTo(2));
  });

  test(
    'Failed sleep save can preserve local session until success finish',
    () async {
      SharedPreferences.setMockInitialValues({});
      await LogTimerState.instance.load();
      final start = DateTime(2026, 6, 29, 8);

      await LogTimerState.instance.startSleep('c1', start);
      expect(LogTimerState.instance.pendingSleepStart('c1'), start);

      await LogTimerState.instance.finishSleep('c1');
      expect(LogTimerState.instance.pendingSleepStart('c1'), isNull);
    },
  );

  test('Pumping timer remains associated with its original child', () async {
    SharedPreferences.setMockInitialValues({});
    await LogTimerState.instance.load();
    final start = DateTime(2026, 7, 3, 8);

    await LogTimerState.instance.startPumping('c1', start);

    expect(LogTimerState.instance.pendingPumpingStart('c1'), start);
    expect(LogTimerState.instance.pendingPumpingStart('c2'), isNull);

    await LogTimerState.instance.finishPumping('c2');
    expect(LogTimerState.instance.pendingPumpingStart('c1'), start);

    await LogTimerState.instance.finishPumping('c1');
    expect(LogTimerState.instance.pendingPumpingStart('c1'), isNull);
  });

  testWidgets(
    'Numuw app shows setup error without Supabase config immediately',
    (tester) async {
      await tester.pumpWidget(const NumuwApp(startupError: 'missing config'));
      await tester.pump();
      expect(find.text('missing config'), findsWidgets);
    },
  );

  testWidgets('MainShell lazily creates unopened tabs', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: MainShell(),
        ),
      ),
    );
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(QuickLogScreen), findsNothing);
  });

  testWidgets('Basic RTL widget smoke test', (tester) async {
    await tester.pumpWidget(const NumuwApp(startupError: 'missing config'));
    final directionality = tester.widget<Directionality>(
      find.byType(Directionality).first,
    );
    expect(directionality.textDirection, TextDirection.rtl);
  });

  testWidgets('Sign in validation shows email and password errors', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: SignInScreen(),
        ),
      ),
    );

    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pump();

    expect(find.text('اكتبي البريد الإلكتروني.'), findsOneWidget);
    expect(
      find.text('كلمة المرور يجب أن تكون 6 أحرف على الأقل.'),
      findsOneWidget,
    );
  });

  testWidgets('Sign up validation shows name email and password errors', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: SignUpScreen(),
        ),
      ),
    );

    final submitButton = find.text('إنشاء الحساب');
    await tester.ensureVisible(submitButton);
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    await tester.pump();

    expect(find.text('اكتبي اسمكِ.'), findsOneWidget);
    expect(find.text('اكتبي البريد الإلكتروني.'), findsOneWidget);
    expect(
      find.text('كلمة المرور يجب أن تكون 10 أحرف على الأقل.'),
      findsOneWidget,
    );
    expect(find.text('أكدي كلمة المرور.'), findsOneWidget);
  });

  testWidgets('Basic RTL pumping-screen widget test', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SingleChildScrollView(child: PumpingLogPane(onBack: () {})),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('شفط'), findsWidgets);
    expect(find.text('حفظ جلسة الشفط'), findsOneWidget);
    expect(find.text('الجانبان'), findsOneWidget);
  });
}

CareEvent _sleep(String id, DateTime startedAt, DateTime? endedAt) => CareEvent(
  id: id,
  childId: 'c',
  createdBy: 'u',
  eventType: 'sleep',
  startedAt: startedAt,
  endedAt: endedAt,
);

CareEvent _feeding(String id, DateTime startedAt) => CareEvent(
  id: id,
  childId: 'c1',
  createdBy: 'u1',
  eventType: 'feeding',
  startedAt: startedAt,
  feedingMethod: 'breast',
  metadata: const {
    'feeding_methods': ['breast'],
  },
);

ChildProfile _child(String id) => ChildProfile(
  id: id,
  createdBy: 'u1',
  name: id,
  stage: 'born',
  gender: 'female',
  feedingType: 'breast',
);

CareEvent _pumping(
  String id,
  DateTime startedAt, {
  required double amount,
  String childId = 'c1',
  Map<String, dynamic>? metadata,
}) => CareEvent(
  id: id,
  childId: childId,
  createdBy: 'u1',
  eventType: 'pumping',
  startedAt: startedAt,
  side: 'both',
  amountMl: amount,
  metadata: metadata ?? <String, dynamic>{},
);
