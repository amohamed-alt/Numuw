import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/services/notification_service.dart';

void main() {
  group('parseNotificationPayload', () {
    test('routes feeding reminders to quick log and preserves child id', () {
      final destination = parseNotificationPayload('feeding:child-123');

      expect(destination.type, NotificationDestinationType.quickLog);
      expect(destination.eventType, 'feeding');
      expect(destination.childId, 'child-123');
    });

    test('routes medicine reminders to quick log', () {
      final destination = parseNotificationPayload('medicine:child-456');

      expect(destination.type, NotificationDestinationType.quickLog);
      expect(destination.eventType, 'medicine');
      expect(destination.childId, 'child-456');
    });

    test('routes vaccination reminders to vaccination section', () {
      final destination = parseNotificationPayload('vaccination:child-789');

      expect(destination.type, NotificationDestinationType.vaccinations);
      expect(destination.eventType, 'vaccination');
      expect(destination.childId, 'child-789');
    });

    test('unknown and empty payloads fail closed to home', () {
      expect(
        parseNotificationPayload('unknown:value').type,
        NotificationDestinationType.home,
      );
      expect(
        parseNotificationPayload(null).type,
        NotificationDestinationType.home,
      );
      expect(
        parseNotificationPayload('   ').type,
        NotificationDestinationType.home,
      );
    });
  });
}
