import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/core/formatters/arabic_formatters.dart';
import 'package:flutter_application_1/core/numuw_app.dart';
import 'package:flutter_application_1/models/care_event.dart';
import 'package:flutter_application_1/models/child_profile.dart';
import 'package:flutter_application_1/repositories/dashboard_repository.dart';

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

  test('Dashboard sleep calculation sums overlapping sleep events', () {
    final start = DateTime(2026, 6, 29);
    final end = start.add(const Duration(days: 1));
    final now = DateTime(2026, 6, 29, 10);
    final events = [
      CareEvent(
        id: '1',
        childId: 'c',
        createdBy: 'u',
        eventType: 'sleep',
        startedAt: DateTime(2026, 6, 29, 1),
        endedAt: DateTime(2026, 6, 29, 3),
      ),
      CareEvent(
        id: '2',
        childId: 'c',
        createdBy: 'u',
        eventType: 'sleep',
        startedAt: DateTime(2026, 6, 29, 9),
      ),
    ];
    expect(
      DashboardRepository.calculateSleepToday(events, start, end, now),
      const Duration(hours: 3),
    );
  });

  testWidgets('Numuw app shows setup error without Supabase config', (
    tester,
  ) async {
    await tester.pumpWidget(
      const NumuwApp(startupError: 'إعدادات Supabase غير مكتملة'),
    );
    expect(find.text('إعدادات مطلوبة'), findsOneWidget);
  });
}
