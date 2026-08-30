import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('weekly share keeps Arabic copy and Natural Organic presentation', () {
    final source = File('lib/screens/weekly_share_screen.dart').readAsStringSync();

    expect(source, contains("title: 'كارت الأسبوع'"));
    expect(source, contains('ملخص بسيط قابل للمشاركة من سجلات طفلك'));
    expect(source, contains('NumuwOrganicIconName.growth'));
    expect(source, contains('NumuwEntrance('));
    expect(source, contains('هذه مقارنة للسجلات فقط وليست تقييمًا طبيًا.'));

    for (final mojibakeMarker in <String>['Ø', 'Ù', 'ðŸ', 'Ã', 'Â']) {
      expect(
        source,
        isNot(contains(mojibakeMarker)),
        reason: 'Weekly share must not regress to mojibake: $mojibakeMarker',
      );
    }
  });
}
