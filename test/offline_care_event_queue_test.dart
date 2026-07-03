import 'package:flutter_application_1/services/offline_care_event_queue.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('OfflineCareEventQueue', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('stores and restores pending care event insert payloads', () async {
      final queue = OfflineCareEventQueue.instance;
      final payload = {
        'child_id': 'child-1',
        'created_by': 'user-1',
        'event_type': 'feeding',
        'started_at': '2026-07-03T10:00:00.000Z',
        'metadata': <String, dynamic>{},
      };

      await queue.enqueueInsert(payload);
      final pending = await queue.pendingInserts();

      expect(pending, hasLength(1));
      expect(pending.single['child_id'], 'child-1');
      expect(pending.single['event_type'], 'feeding');
    });

    test(
      'replacePending clears storage when no pending payload remains',
      () async {
        final queue = OfflineCareEventQueue.instance;
        await queue.enqueueInsert({'child_id': 'child-1'});

        await queue.replacePending([]);

        expect(await queue.pendingInserts(), isEmpty);
      },
    );
  });
}
